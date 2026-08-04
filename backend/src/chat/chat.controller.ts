import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { ChatService } from "@backend/chat/chat.service";
import { ChatRequestDTO } from "@backend/chat/model/api/chat.request.dto";
import { ChatHistory } from "@backend/chat/model/chat.history.model";
import { ChatOverview } from "@backend/chat/model/chat.overview.model";
import { ChatOverviewType } from "@backend/chat/model/chat.overview.type";
import { Configuration } from "@backend/config/core";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, Body, ConflictException, Controller, Get, Logger, Post, Query } from "@nestjs/common";
import { ApiConflictResponse, ApiOkResponse, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import cronParser from "cron-parser";
import { startCase } from "lodash";

/** This controller provides the endpoint for chatting with LLM's */
@Controller("chat")
@ApiTags("Chat")
@AuthGuard.attach()
export class ChatController {
  private readonly logger = new Logger("controller:chat");

  constructor(
    private readonly chatService: ChatService,
    private readonly sseService: SSEService,
  ) {}

  @Post("new")
  @ApiOperation({ summary: "Utilizes the LLM prompt engine to help you discuss your finances." })
  @ApiOkResponse({ description: "Returns the generated text from the prompt." })
  @ApiConflictResponse({ description: "Thrown if the LLM is already running a request for the current user." })
  @EnabledGuard.attachDemoMode()
  async new(@CurrentUser() user: User, @Body() data: ChatRequestDTO) {
    const isLoading = await ChatHistory.count({ where: { user: { id: user.id }, isThinking: true } });
    if (isLoading > 0) throw new ConflictException("A request is already running. Please try again later");
    if (data.message.trim() === "") throw new BadRequestException("No valid message given");

    this.sseService.sendToUser(user, SSEEventType.CHAT, await new ChatHistory(user, data.message, "user").insert());
    const chat = await new ChatHistory(user, ChatHistory.DEFAULT_MODEL_TEXT, "model", undefined, true).insert();
    this.sseService.sendToUser(user, SSEEventType.CHAT, chat);

    const model = await this.chatService.getModel(user);
    return await model.generateChatContent(chat, data.timeframe);
  }

  @Get("history")
  @ApiOperation({ summary: "Returns the chat history for previous LLM conversations." })
  @ApiOkResponse({ description: "Returns the chat history", type: [ChatHistory] })
  async history(@CurrentUser() user: User) {
    return await ChatHistory.find({ where: { user: { id: user.id } }, order: { time: "DESC" } });
  }

  @Get("overview")
  @ApiOperation({ summary: "Returns the financial overview for the user based on the specified overview type." })
  @ApiQuery({
    name: "type",
    enum: ChatOverviewType,
    required: false,
    description: "The type of overview to retrieve (defaults to 'accounts').",
  })
  @ApiOkResponse({ description: "Returns the requested chat overview.", type: ChatOverview })
  async getOverview(@CurrentUser() user: User, @Query("type") type: ChatOverviewType = ChatOverviewType.accounts) {
    let status = await ChatOverview.findOne({ where: { user: { id: user.id }, type } });

    if (status) {
      // Find the last scheduled sync time before NOW using the configured cron schedule
      const cron = Configuration.providers.simpleFIN.syncFrequency;
      const interval = cronParser.parse(cron, { currentDate: new Date() });
      const lastScheduledSyncTime = interval.prev().toDate();

      // If status was generated AFTER the last scheduled sync execution, it is still fresh
      const isFresh = new Date(status.time).getTime() >= lastScheduledSyncTime.getTime();
      if (isFresh) return status;
    }

    // Generate a fresh overview if status doesn't exist or is stale
    this.logger.debug(`${startCase(type)} overview out of date, regenerating for user ${user.username}`);
    const model = await this.chatService.getModel(user);
    return await model.generateOverview(type);
  }
}
