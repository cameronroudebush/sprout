import { AdminGuard } from "@backend/auth/guard/admin.guard";
import { Configuration } from "@backend/config/core";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { DatabaseBackupJob } from "@backend/core/jobs/backup";
import { Controller, Get } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { startCase } from "lodash";
import { name } from "../../package.json";

/** This controller contains core functionality that is not placed better anywhere else. */
@Controller("core")
@ApiTags("Core")
export class CoreController {
  constructor(private readonly databaseBackupJob: DatabaseBackupJob) {}

  @Get("heartbeat")
  @ApiOperation({
    summary: "Check application status.",
    description: "Provides a return message if the app is running.",
  })
  @ApiOkResponse({ description: "Application status retrieved successfully.", type: String })
  async heartbeat() {
    return `${startCase(name)} is alive!`;
  }

  @Get("backups")
  @ApiOperation({
    summary: "Get database backup details.",
    description: "Returns a list of all current database backups along with size and GFS tier metadata.",
  })
  @ApiOkResponse({ description: "Backup metadata retrieved successfully." })
  @AdminGuard.attach()
  @EnabledGuard.attach(Configuration.database.backup.enabled)
  async getBackups() {
    return this.databaseBackupJob.getBackupSummary();
  }
}
