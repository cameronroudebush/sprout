import { Configuration } from "@backend/config/core";
import { startCase } from "lodash";
import { name } from "../package.json";
import { ConfigurationService } from "./config/config.service";
import { SproutLogger } from "./core/logger";

/**
 *  Manually load configuration before any of the rest of the app is loaded. This is because we reference the config
 *    very early in a lot of class construction.
 */
const projName = startCase(name);
new ConfigurationService(new SproutLogger(projName, { logLevels: ["verbose"] })).load();
Configuration.isRunningScript = (Configuration.isDevBuild as any) && process.argv[2] != null;

import { TimeZone } from "@backend/config/model/tz";
import { EncryptionTransformer } from "@backend/core/decorator/encryption.decorator";
import { setupOpenApiHelp } from "@backend/core/openapi";
import { DatabaseService } from "@backend/database/database.service";
import { DatabaseBase } from "@backend/database/model/database.base";
import { JobsService } from "@backend/jobs/jobs.service";
import { ClassSerializerInterceptor, Logger, LogLevel, ValidationPipe } from "@nestjs/common";
import { NestFactory, Reflector } from "@nestjs/core";
import { NestExpressApplication } from "@nestjs/platform-express";
import compression from "compression";
import cookieParser from "cookie-parser";
import { AppModule } from "./app.module";
import { generateOpenApiSpec } from "./scripts/generate.api-spec";
import { populateDemoData } from "./scripts/populate.demo.data";

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
      default:
        throw new Error("Failed to locate matching script to execute");
    }
  } catch (e) {
    Logger.error(e);
    process.exit(1);
  }
}

/** Main function for kicking off the application */
async function main() {
  // Check if we have scripts to run
  if (Configuration.isRunningScript) await checkScript();

  const logger = new Logger("main");
  try {
    // Set log levels based on environment
    const logLevels: LogLevel[] = Configuration.isDevBuild ? ["verbose"] : Configuration.server.logLevels;

    // Initialize the Nest app
    const app = await NestFactory.create<NestExpressApplication>(AppModule, {
      logger: new SproutLogger(projName, { logLevels }),
      cors: !Configuration.isDevBuild,
    });
    // All endpoints live under /api
    app.setGlobalPrefix(Configuration.server.basePath);
    // Enable validation
    app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }));
    // Enable class-transformer for response serialization
    app.useGlobalInterceptors(new ClassSerializerInterceptor(app.get(Reflector)));
    // Enable cookie handling
    app.use(cookieParser(Configuration.encryptionKey));
    // Enable compression to help shrink responses
    app.use(compression());
    // Trust proxy headers
    app.set("trust proxy", 1);
    if (Configuration.isDevBuild)
      app.enableCors({
        origin: ["http://localhost:8989", "http://localhost:8001"],
        methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
        credentials: true,
      });

    logger.log(`Starting ${Configuration.appName} ${Configuration.version} in ${Configuration.isDevBuild ? "development" : "production"} mode`);
    logger.log(`Built on ${TimeZone.formatDate(new Date(process.env["BUILD_DATE"]!))}`);

    // Validate encryption code status
    if (!Configuration.encryptionKey || Configuration.encryptionKey.length / 2 !== EncryptionTransformer.REQUIRED_KEY_LENGTH)
      throw new Error(
        `An encryption key must be specified for Sprout to start and must be exactly ${EncryptionTransformer.REQUIRED_KEY_LENGTH} bytes (${EncryptionTransformer.REQUIRED_KEY_LENGTH * 2} hex characters). See the configuration guide for more info.\n` +
          `Here is a randomly generated key you might want to use: ${EncryptionTransformer.generateRandomEncryptionKey()}`,
      );

    // Inform of auth information
    logger.log(`Authentication Strategy: ${Configuration.server.auth.type}`);
    if (Configuration.server.auth.type === "oidc") Configuration.server.auth.oidc.validate();

    // Configure OpenAPI page
    setupOpenApiHelp(app);

    // Inform where the log file is
    logger.log(`Config file located at ${app.get(ConfigurationService).configFileLocation}`);
    // Initialize database
    const databaseService = app.get(DatabaseService);
    await databaseService.init();
    DatabaseBase.database = databaseService;
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
