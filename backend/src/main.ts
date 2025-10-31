import { Configuration } from "@backend/config/core";
import { TimeZone } from "@backend/config/model/tz";
import { DatabaseService } from "@backend/database/database.service";
import { DatabaseBase } from "@backend/database/model/database.base";
import { JobsService } from "@backend/jobs/jobs.service";
import { ProviderService } from "@backend/providers/provider.service";
import { ClassSerializerInterceptor, INestApplication, Logger, LogLevel, ValidationPipe } from "@nestjs/common";
import { NestFactory, Reflector } from "@nestjs/core";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import { startCase } from "lodash";
import { SwaggerTheme, SwaggerThemeNameEnum } from "swagger-themes";
import { name } from "../package.json";
import { ConfigurationService } from "./config/config.service";
import { SproutLogger } from "./core/logger";
import { generateOpenApiSpec } from "./scripts/generate.api-spec";
import { populateDemoData } from "./scripts/populate.demo.data";

// Manually load configuration before the app module is loaded so we can use the config within the app module.
new ConfigurationService().load();
// Now import the app module since we've got that ready to go
import { AppModule } from "./app.module";

/**
 * This allows us to run this app and then execute a specific script
 *  instead. This helps configure the app like it would normally be but then allows us to execute specific functionality.
 */
export async function checkScript() {
  const scriptName = process.argv[2];
  try {
    switch (scriptName) {
      case "generate.api-spec":
        await generateOpenApiSpec(process.argv[3]);
        process.exit(0);
      case "populate.demo.data":
        await populateDemoData(parseInt(process.argv[3] ?? "90"));
        process.exit(0);
    }
  } catch (e) {
    Logger.error(e);
    process.exit(1);
  }
}

/** Creates the swagger document generator and returns it for use in the app */
export function createSwaggerDoc(app: INestApplication) {
  const projName = startCase(name);
  const swaggerTitle = `${projName} API`;
  const description = `Welcome to the ${projName} API documentation. This document provides a comprehensive guide to all available endpoints. Use the sections below to explore different parts of the API.`;
  const version = Configuration.version;
  const config = new DocumentBuilder()
    .setTitle(swaggerTitle)
    .setDescription(description)
    .setVersion(version)
    .addBearerAuth({ type: "http", description: "This authentication utilizes the JWT given during user login." })
    .addTag("Core", `Provides essential application functionalities, including manual data synchronization and initial setup checks.`)
    .addTag("Config", `Manages application-wide settings and configurations.`)
    .addTag("User", "Manage user authentication, creation, and profile information.")
    .addTag("User Config", "Manage user-specific application settings and configurations.")
    .addTag("Account", "Manage financial accounts, including retrieval, editing, and linking with financial providers.")
    .addTag("Transaction", "Access and manage financial transactions, including searching, editing, and analyzing spending patterns.")
    .addTag("Transaction Rule", "Define and manage rules for automatic transaction categorization during synchronization.")
    .addTag("Category", "Define and manage categories which assist in grouping transactions.")
    .addTag("Holding", "Define and manage holdings which tracks stock information.")
    .addTag("Net Worth", "Provides endpoints to track and visualize a user's net worth over time.")
    .addTag("Cash Flow", "Provides endpoints to analyze and visualize cash flow, showing how money moves between income and expenses using categories.")
    .build();
  return () => {
    const document = SwaggerModule.createDocument(app, config);

    // Add a global 429 response to all endpoints since we use a global ThrottlerGuard.
    for (const path of Object.values(document.paths))
      for (const method of Object.values(path))
        method.responses["429"] = {
          description: "Too Many Requests. The user has sent too many requests in a given amount of time.",
        };

    return document;
  };
}

/** Main function for kicking off the application */
async function main() {
  // Check if we have scripts to run
  if (Configuration.isDevBuild) await checkScript();

  const projName = startCase(name);
  const swaggerTitle = `${projName} API`;
  const logger = new Logger("main");
  try {
    // Set log levels based on environment
    const logLevels: LogLevel[] = Configuration.isDevBuild ? ["verbose"] : Configuration.server.logLevels;

    // Initialize the Nest app
    const app = await NestFactory.create(AppModule, {
      logger: new SproutLogger(projName, { logLevels }),
      cors: true,
    });
    // All endpoints live under /api
    app.setGlobalPrefix(Configuration.server.basePath);
    // Enable validation
    app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }));
    // Enable class-transformer for response serialization
    app.useGlobalInterceptors(new ClassSerializerInterceptor(app.get(Reflector)));

    logger.log(`Starting ${Configuration.appName} ${Configuration.version} in ${Configuration.isDevBuild ? "development" : "production"} mode`);
    logger.log(`Built on ${TimeZone.formatDate(new Date(process.env["BUILD_DATE"]!))}`);

    // Configure Swagger
    if (Configuration.isDevBuild) {
      const theme = new SwaggerTheme();
      SwaggerModule.setup(Configuration.server.basePath, app, createSwaggerDoc(app), {
        customSiteTitle: swaggerTitle,
        swaggerOptions: { defaultModelsExpandDepth: -1 },
        customCss: theme.getBuffer(SwaggerThemeNameEnum.DARK),
        customfavIcon: "https://sprout.croudebush.net/assets/favicon-bg.svg",
      });
    }

    // Inform where the log file is
    logger.log(`Config file located at ${app.get(ConfigurationService).configFileLocation}`);
    // Initialize database
    const databaseService = app.get(DatabaseService);
    await databaseService.init();
    DatabaseBase.database = databaseService;
    // Init our providers
    await app.get(ProviderService).init();
    // Initialize background jobs
    await app.get(JobsService).start();
    await app.listen(Configuration.server.port);
    logger.log(`Server ready on port ${Configuration.server.port}`);
  } catch (e) {
    logger.error(e as Error);
    logger.error(`${projName} crashed on startup. Exiting...`);
    process.exit(1);
  }
}

// Execute main so long as this file is not being imported
if (require.main === module) main();
