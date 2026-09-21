import { AppModule } from "@backend/app.module";
import { SproutLogger } from "@backend/core/logger";
import { DatabaseService } from "@backend/database/database.service";
import { PRETTIER_OPTS } from "@backend/scripts/util";
import { Logger } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";
import path from "path";
import prettier from "prettier";
import { CommandUtils } from "typeorm/commands/CommandUtils.js";
import { MigrationGenerateCommand } from "typeorm/commands/MigrationGenerateCommand.js";

/** Generates a TypeORM database migration file programmatically. */
export async function generateMigration(migrationName: string) {
  const app = await NestFactory.create(AppModule, {
    logger: new SproutLogger("Database Migration Service"),
  });
  const logger = new Logger("Migration");

  try {
    logger.log("Initializing database connection...");
    const database = app.get(DatabaseService);

    // Apply SQLite PRAGMA configuration override if required
    const originalInitialize = database.source!.initialize.bind(database.source);
    database.source!.initialize = async () => {
      const result = await originalInitialize();
      await database.setSQLitePRAGMA(false);
      return result;
    };

    if (!database.source!.isInitialized) await database.source!.initialize();

    logger.log(`Generating migration: ${migrationName}...`);

    // Obtain sql query execution logs / schema updates comparison
    const sqlInMemory = await database.source!.driver.createSchemaBuilder().log();
    const upSqls: string[] = [];
    const downSqls: string[] = [];

    // Extract UP queries
    sqlInMemory.upQueries.forEach((upQuery) => {
      upSqls.push(
        `        await queryRunner.query(\`${upQuery.query.replace(/`/g, "\\`")}\`${
          upQuery.parameters && upQuery.parameters.length ? `, ${JSON.stringify(upQuery.parameters)}` : ""
        });`,
      );
    });

    // Extract DOWN queries
    sqlInMemory.downQueries.forEach((downQuery) => {
      downSqls.push(
        `        await queryRunner.query(\`${downQuery.query.replace(/`/g, "\\`")}\`${
          downQuery.parameters && downQuery.parameters.length ? `, ${JSON.stringify(downQuery.parameters)}` : ""
        });`,
      );
    });

    if (!upSqls.length) {
      logger.log("No changes in database schema were found - no migration needed.");
      await app.close();
      return;
    }

    const timestamp = Date.now();
    const extension = ".ts";
    const camelCaseName = migrationName.charAt(0).toUpperCase() + migrationName.slice(1);
    const fileName = `${timestamp}-${migrationName}${extension}`;
    const targetDir = path.resolve(process.cwd(), "src/database/migration/sqlite");

    const rawFileContent = (MigrationGenerateCommand as any).getTemplate(`${camelCaseName}${timestamp}`, timestamp, upSqls, downSqls.reverse());
    // Format the generated TypeScript migration code with Prettier
    const formattedFileContent = await prettier.format(rawFileContent, { ...PRETTIER_OPTS, parser: "typescript", printWidth: 480 });

    const outputPath = path.join(targetDir, fileName);
    logger.log(`Writing migration to ${outputPath}`);

    await CommandUtils.createFile(outputPath, formattedFileContent);
    logger.log(`Migration ${fileName} has been generated successfully.`);
  } catch (error) {
    logger.error("Failed to generate migration:", error);
    throw error;
  } finally {
    await app.close();
  }
}
