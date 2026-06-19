import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { UpdateInstitutionRequest } from "@backend/institution/model/api/institution.update.dto";
import { Institution } from "@backend/institution/model/institution.model";
import { SSEEventType } from "@backend/sse/model/event.model";
import { User } from "@backend/user/model/user.model";
import { Body, Controller, NotFoundException, Param, Patch } from "@nestjs/common";
import { ApiBody, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { SSEService } from "../sse/sse.service";

/**
 * This controller provides the endpoint for all Institution related content
 */
@Controller("institution")
@ApiTags("Institution")
@AuthGuard.attach()
export class InstitutionController {
  constructor(private readonly sseService: SSEService) {}

  @Patch(":id/update")
  @ApiOperation({
    summary: "Update institution.",
    description: "Updates properties supported by the DTO for the specific institution.",
  })
  @ApiOkResponse({
    description: "Institution updated successfully.",
    type: Institution,
  })
  @ApiNotFoundResponse({
    description: "Institution with the specified ID not found or does not belong to the user.",
  })
  @ApiBody({ type: UpdateInstitutionRequest })
  @EnabledGuard.attachDemoMode()
  async update(@Param("id") id: string, @CurrentUser() user: User, @Body() body: UpdateInstitutionRequest): Promise<Institution> {
    const matchingInstitution = await Institution.findOne({ where: { id: id, user: { id: user.id } } });
    if (!matchingInstitution) throw new NotFoundException(`Institution with ID ${id} not found or does not belong to the user.`);
    matchingInstitution.iconType = body.iconType;
    const result = await matchingInstitution.update();
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
    return result;
  }
}
