import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { SSEData } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { Controller, Sse } from "@nestjs/common";
import { ApiExtraModels, ApiOkResponse, ApiOperation, ApiTags, getSchemaPath } from "@nestjs/swagger";
import { Observable } from "rxjs";

/** This controller is used for creating the endpoint for the clients to connect to the SSE client. */
@Controller("sse")
@ApiTags("Core")
@AuthGuard.attach()
export class SSEController {
  constructor(private readonly sseService: SSEService) {}

  /**
   * Establishes a Server-Sent Events (SSE) connection for the authenticated user.
   *
   * This endpoint keeps a persistent connection open, allowing the server to push real-time
   * updates to the client (e.g., synchronization status, notifications). The connection
   * will automatically close if the client disconnects.
   */
  @Sse()
  @ApiOperation({ summary: "Subscribe to real-time server events to allow the server to inform our client of various info." })
  @ApiOkResponse({
    description: "Connection established. Awaiting events.",
    content: {
      "text/event-stream": {
        schema: { $ref: getSchemaPath(SSEData) },
      },
    },
  })
  @ApiExtraModels(SSEData)
  sse(@CurrentUser() user: User): Observable<MessageEvent> {
    return this.sseService.subscribe(user);
  }
}
