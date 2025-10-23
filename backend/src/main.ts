import { Configuration } from "@backend/config/core";
import { DatabaseService } from "@backend/database/database.service";
import { DatabaseBase } from "@backend/database/model/database.base";
import { JobsService } from "@backend/jobs/jobs.service";
import { ProviderService } from "@backend/providers/provider.service";
import { Logger, LogLevel, ValidationPipe } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import { startCase } from "lodash";
import { SwaggerTheme, SwaggerThemeNameEnum } from "swagger-themes";
import { name } from "../package.json";
import { AppModule } from "./app.module";
import { ConfigurationService } from "./config/config.service";
import { SproutLogger } from "./core/logger";

/** Main function for kicking off the application */
async function main() {
  const logger = new Logger("main");
  try {
    // Set log levels based on environment
    const logLevels: LogLevel[] = Configuration.isDevBuild ? ["verbose"] : Configuration.server.logLevels;

    // Initialize the Nest app
    const app = await NestFactory.create(AppModule, {
      logger: new SproutLogger(startCase(name), { logLevels }),
    });

    // Enable validation
    app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }));

    logger.log(`Starting ${Configuration.appName} ${Configuration.version} in ${Configuration.isDevBuild ? "development" : "production"} mode`);

    // Configure Swagger
    const theme = new SwaggerTheme();
    const swaggerTitle = `${startCase(name)} API`;
    const description = `This documentation contains endpoint information ${name}. Below you will find the various supported API endpoints.`;
    const version = Configuration.version;
    const config = new DocumentBuilder()
      .setTitle(swaggerTitle)
      .setDescription(description)
      .setVersion(version)
      .addBearerAuth()
      .addTag("User", "Endpoints related to users within the app.")
      .build();
    const documentFactory = () => SwaggerModule.createDocument(app, config);
    SwaggerModule.setup("api", app, documentFactory, { customCss: theme.getBuffer(SwaggerThemeNameEnum.DARK) });

    // Initialize config
    app.get(ConfigurationService).load();
    // Initialize database
    const databaseService = app.get(DatabaseService);
    await databaseService.init();
    DatabaseBase.database = databaseService;
    // Init our providers
    await app.get(ProviderService).init();
    // Initialize background jobs
    await app.get(JobsService).start();
    await app.listen(Configuration.server.port);
    logger.log(`Server ready on ${Configuration.server.port}`);
  } catch (e) {
    logger.error(e as Error);
    process.exit(1);
  }
}

// Execute main so long as this file is not being imported
if (require.main === module) main();
