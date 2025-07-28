import { Configuration } from "@backend/config/core";
import { Logger } from "@backend/logger";
import fs from "fs";
import path from "path";
import { BackgroundJob } from "../background.job";

/** This class defines a background job to execute routinely for backing up the database. */
export class DatabaseBackup extends BackgroundJob<any> {
  constructor() {
    super("db-backup", Configuration.database.backup.time);
  }

  override async start() {
    // Always perform an initial backup on app start
    return super.start(true);
  }

  protected async update() {
    // Create the backup directory if it doesn't exist
    if (!fs.existsSync(Configuration.database.backup.directory)) fs.mkdirSync(Configuration.database.backup.directory, { recursive: true });

    const dbPath = Configuration.database.dbConfig.database as string;
    const backupFileName = `sprout_backup_${new Date().toISOString().replace(/:/g, "-")}.sqlite`;
    const backupPath = path.join(Configuration.database.backup.directory, backupFileName);

    Logger.info(`Creating database backup: ${backupPath}`, this.logConfig);
    fs.copyFileSync(dbPath, backupPath);
    Logger.success("Database backup created successfully!", this.logConfig);

    // Clean up old backups
    const backupFiles = fs
      .readdirSync(Configuration.database.backup.directory)
      .filter((file) => file.startsWith("sprout_backup_") && file.endsWith(".sqlite"))
      .sort()
      .reverse(); // Sort descending to keep the newest

    if (backupFiles.length > Configuration.database.backup.count) {
      const filesToDelete = backupFiles.slice(Configuration.database.backup.count);
      for (const file of filesToDelete) {
        const filePath = path.join(Configuration.database.backup.directory, file);
        Logger.info(`Deleting old backup: ${filePath}`, this.logConfig);
        fs.unlinkSync(filePath);
      }
    }
  }
}
