import { Configuration } from "@backend/config/core";
import { TimeZone } from "@backend/config/model/tz";
import { BackgroundJob } from "@backend/core/jobs/model/job-base";
import { Injectable } from "@nestjs/common";
import fs from "fs";
import path from "path";

interface BackupEntry {
  fileName: string;
  filePath: string;
  date: Date;
  sizeBytes: number;
}

export interface EvaluatedBackup extends BackupEntry {
  tiers: string[];
}

/** This class defines a background job to execute routinely for backing up the database using a GFS retention policy. */
@Injectable()
export class DatabaseBackupJob extends BackgroundJob<any> {
  constructor() {
    super("db:backup", Configuration.database.backup.time, Configuration.database.backup.enabled, true);
  }

  protected async update() {
    if (!fs.existsSync(Configuration.database.backup.directory)) {
      fs.mkdirSync(Configuration.database.backup.directory, { recursive: true });
    }

    const dbPath = Configuration.database.dbConfig.database as string;
    const nowAsString = TimeZone.formatDate(new Date()).replace(/:/g, "-").replaceAll(" ", "_");
    const backupFileName = `sprout_backup_${nowAsString}.sqlite`;
    const backupPath = path.join(Configuration.database.backup.directory, backupFileName);

    this.logger.log(`Creating database backup: ${backupPath}`);
    fs.copyFileSync(dbPath, backupPath);
    this.logger.log("Database backup created successfully!");

    this.pruneGfsBackups();
  }

  private parseDateFromFileName(fileName: string): Date | null {
    const match = fileName.match(/sprout_backup_(\d{4})-(\d{2})-(\d{2})_(\d{2})-(\d{2})-(\d{2})/);
    if (!match) return null;

    const [, year, month, day, hour, minute, second] = match.map(Number);
    return new Date(year!, month! - 1, day, hour, minute, second);
  }

  private evaluateBackups(): EvaluatedBackup[] {
    const backupDir = Configuration.database.backup.directory;
    if (!fs.existsSync(backupDir)) return [];

    const backupFiles = fs.readdirSync(backupDir).filter((file) => file.startsWith("sprout_backup_") && file.endsWith(".sqlite"));

    const parsedBackups: BackupEntry[] = [];
    for (const file of backupFiles) {
      const parsedDate = this.parseDateFromFileName(file);
      if (!parsedDate) continue;

      const filePath = path.join(backupDir, file);
      const stats = fs.statSync(filePath);
      parsedBackups.push({ fileName: file, filePath, date: parsedDate, sizeBytes: stats.size });
    }

    // Sort descending (newest first)
    parsedBackups.sort((a, b) => b.date.getTime() - a.date.getTime());

    const dailyKeep = Configuration.database.backup.gfs?.dailyCount ?? 7;
    const weeklyKeep = Configuration.database.backup.gfs?.weeklyCount ?? 4;
    const monthlyKeep = Configuration.database.backup.gfs?.monthlyCount ?? 12;
    const quarterlyKeep = Configuration.database.backup.gfs?.quarterlyCount ?? 4;
    const yearlyKeep = Configuration.database.backup.gfs?.yearlyCount ?? 3;

    // Standard bucket keys (strictly 1 file per period)
    const getDailyKey = (d: Date) => `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`;
    const getWeekKey = (d: Date) => {
      const target = new Date(d.valueOf());
      const dayNr = (d.getDay() + 6) % 7;
      target.setDate(target.getDate() - dayNr + 3);
      const firstThursday = target.valueOf();
      target.setMonth(0, 1);
      if (target.getDay() !== 4) target.setMonth(0, 1 + ((4 - target.getDay() + 7) % 7));
      const weekNumber = 1 + Math.round((firstThursday - target.valueOf()) / 604800000);
      return `${target.getFullYear()}-W${weekNumber}`;
    };
    const getMonthKey = (d: Date) => `${d.getFullYear()}-${d.getMonth() + 1}`;
    const getQuarterKey = (d: Date) => `${d.getFullYear()}-Q${Math.floor(d.getMonth() / 3) + 1}`;
    const getYearKey = (d: Date) => `${d.getFullYear()}`;

    const collectTierBackups = (getKey: (d: Date) => string, limit: number) => {
      const buckets = new Map<string, BackupEntry>();
      for (const backup of parsedBackups) {
        const key = getKey(backup.date);
        if (!buckets.has(key)) buckets.set(key, backup);
      }
      return new Set(
        Array.from(buckets.values())
          .slice(0, limit)
          .map((b) => b.fileName),
      );
    };

    const dailySet = collectTierBackups(getDailyKey, dailyKeep);
    const weeklySet = collectTierBackups(getWeekKey, weeklyKeep);
    const monthlySet = collectTierBackups(getMonthKey, monthlyKeep);
    const quarterlySet = collectTierBackups(getQuarterKey, quarterlyKeep);
    const yearlySet = collectTierBackups(getYearKey, yearlyKeep);

    return parsedBackups.map((b) => {
      const tiers: string[] = [];
      if (dailySet.has(b.fileName)) tiers.push("daily");
      if (weeklySet.has(b.fileName)) tiers.push("weekly");
      if (monthlySet.has(b.fileName)) tiers.push("monthly");
      if (quarterlySet.has(b.fileName)) tiers.push("quarterly");
      if (yearlySet.has(b.fileName)) tiers.push("yearly");

      return { ...b, tiers };
    });
  }

  private pruneGfsBackups() {
    const evaluated = this.evaluateBackups();

    for (const backup of evaluated) {
      if (backup.tiers.length === 0) {
        this.logger.log(`Deleting old backup (GFS Prune): ${backup.filePath}`);
        fs.unlinkSync(backup.filePath);
      }
    }
  }

  public getBackupSummary() {
    const evaluated = this.evaluateBackups();
    const totalSizeBytes = evaluated.reduce((acc, b) => acc + b.sizeBytes, 0);

    return {
      totalCount: evaluated.length,
      totalSizeBytes,
      backups: evaluated.map((b) => ({
        fileName: b.fileName,
        date: b.date.toISOString(),
        sizeBytes: b.sizeBytes,
        tiers: b.tiers,
      })),
    };
  }
}
