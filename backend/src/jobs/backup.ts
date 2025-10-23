import { Configuration } from "@backend/config/core";
import { TimeZone } from "@backend/config/tz";
import fs from "fs";
import path from "path";
import { BackgroundJob } from "./base";

/** This class defines a background job to execute routinely for backing up the database. */
export class DatabaseBackup extends BackgroundJob<any> {
  constructor() {
    super("db:backup", Configuration.database.backup.time);
  }

  override async start() {
    // Always perform an initial backup on app start
    return super.start(true);
  }

  protected async update() {
    // Create the backup directory if it doesn't exist
    if (!fs.existsSync(Configuration.database.backup.directory)) fs.mkdirSync(Configuration.database.backup.directory, { recursive: true });

    const dbPath = Configuration.database.dbConfig.database as string;
    const nowAsString = TimeZone.formatDate(new Date()).replace(/:/g, "-").replaceAll(" ", "_");
    const backupFileName = `sprout_backup_${nowAsString}.sqlite`;
    const backupPath = path.join(Configuration.database.backup.directory, backupFileName);

    this.logger.log(`Creating database backup: ${backupPath}`);
    fs.copyFileSync(dbPath, backupPath);
    this.logger.log("Database backup created successfully!");

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
        this.logger.log(`Deleting old backup: ${filePath}`);
        fs.unlinkSync(filePath);
      }
    }
  }
}
