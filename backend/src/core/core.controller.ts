import { Controller, Get } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { startCase } from "lodash";
import { name } from "../../package.json";

/** This controller contains core functionality that is not placed better anywhere else. */
@Controller("core")
@ApiTags("Core")
export class CoreController {
  @Get("heartbeat")
  @ApiOperation({
    summary: "Check application status.",
    description: "Provides a return message if the app is running.",
  })
  @ApiOkResponse({ description: "Application status retrieved successfully.", type: String })
  async heartbeat() {
    return `${startCase(name)} is alive!`;
  }
}
