import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { AuthGuard } from "@backend/core/guard/auth.guard";
import { JobsService } from "@backend/jobs/jobs.service";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { Controller, Get, Put } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { startCase } from "lodash";
import { name } from "../../package.json";

/** This controller contains core functionality that is not placed better anywhere else. */
@Controller("core")
@ApiTags("Core")
export class CoreController {
  constructor(
    private readonly jobService: JobsService,
    private readonly sseService: SSEService,
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

  @Put()
  @ApiOperation({
    summary: "Run a manual sync.",
    description: "Runs a manual sync to update all provider accounts.",
  })
  @ApiOkResponse({ description: "Manual sync completed successfully." })
  @AuthGuard.attach()
  async manualSync(@CurrentUser() user: User) {
    // TODO: This executes all provider syncs for all users which seems excessive.
    // TODO: Add ability to not run another sync if one is already running.
    const sync = await this.jobService.providerSyncJob.updateNow();
    // Inform of the completed sync
    this.sseService.sendToUser(user, "sync", sync);
  }
}
