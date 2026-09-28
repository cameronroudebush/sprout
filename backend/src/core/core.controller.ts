import { AdminGuard } from "@backend/auth/guard/admin.guard";
import { Configuration } from "@backend/config/core";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { PublicURL } from "@backend/core/decorator/public.url.decorator";
import { DatabaseBackupJob } from "@backend/core/jobs/backup";
import { CoreService } from "@backend/core/core.service";
import { User } from "@backend/user/model/user.model";
import { Controller, Get, Header } from "@nestjs/common";
import { ApiExcludeEndpoint, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { startCase } from "lodash-es";
import pkg from "../../package.json" with { type: "json" };
const { name } = pkg;

/** This controller contains core functionality that is not placed better anywhere else. */
@Controller("core")
@ApiTags("Core")
export class CoreController {
  constructor(
    private readonly databaseBackupJob: DatabaseBackupJob,
    private readonly coreService: CoreService,
  ) {}

  @Get("heartbeat")
  @ApiOperation({
    summary: "Check application status.",
    description: "Provides a return message if the app is running.",
  })
  @ApiOkResponse({ description: "Application status retrieved successfully.", type: String })
  async heartbeat() {
    return `${startCase(name)} is alive!`;
  }

  @Get("admin")
  @AdminGuard.attach()
  @Header("Content-Type", "text/html; charset=utf-8")
  @Header("Cache-Control", "no-store")
  @ApiExcludeEndpoint()
  adminDashboard(@CurrentUser() user: User, @PublicURL() publicUrl = "") {
    return this.coreService.getAdminDashboard(user, publicUrl);
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
