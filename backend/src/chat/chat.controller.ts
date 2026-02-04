import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { ChatService } from "@backend/chat/chat.service";
import { ChatRequestDTO } from "@backend/chat/model/api/chat.request.dto";
import { ChatHistory } from "@backend/chat/model/chat.history.model";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, Body, ConflictException, Controller, Get, InternalServerErrorException, Post } from "@nestjs/common";
import { ApiConflictResponse, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { ThrottlerException } from "@nestjs/throttler";

/** This controller provides the endpoint for chatting with LLM's */
@Controller("chat")
@ApiTags("Chat")
@AuthGuard.attach()
export class ChatController {
  constructor(
    private readonly chatService: ChatService,
    private readonly sseService: SSEService,
  ) {}

  @Post("new")
  @ApiOperation({ summary: "Utilizes the LLM prompt engine to help you discuss your finances." })
  @ApiOkResponse({ description: "Returns the generated text from the prompt." })
  @ApiConflictResponse({ description: "Thrown if the LLM is already running a request for the current user." })
  async new(@CurrentUser() user: User, @Body() data: ChatRequestDTO) {
    // Determine if we're still processing a previous response
    const isLoading = await ChatHistory.count({ where: { user: { id: user.id }, isThinking: true } });
    if (isLoading > 0) throw new ConflictException("A request is already running. Please try again later");
    if (data.message.trim() === "") throw new BadRequestException("No valid message given");
    // Generate the prompt for the new message, insert it, and inform the app
    this.sseService.sendToUser(user, SSEEventType.CHAT, await new ChatHistory(user, data.message, "user").insert());
    // Add history tracking for the model response immediately so the frontend knows about it
    const chat = await new ChatHistory(user, "Request failed. Try again later.", "model", undefined, true).insert();
    this.sseService.sendToUser(user, SSEEventType.CHAT, chat);
    try {
      const model = await this.chatService.getModel(user);
      const contents = await this.chatService.buildPrompt(user);
      try {
        const response = await model.generateContent(contents, chat);
        if (response.text === "") throw new InternalServerErrorException("Failed to parse request from the LLM. Try again later.");
        return response.text;
      } catch (e) {
        if ((e as Error)?.message.includes("You exceeded your current quota"))
          throw new ThrottlerException("You have exceeded your request quota. Try again later.");
        else throw e;
      }
    } catch (e) {
      chat.isThinking = false;
      chat.text = (e as Error).message;
      await chat.update();
      this.sseService.sendToUser(user, SSEEventType.CHAT, chat);
      throw e;
    }
  }

  @Get("history")
  @ApiOperation({ summary: "Returns the chat history for previous LLM conversations." })
  @ApiOkResponse({ description: "Returns the chat history", type: [ChatHistory] })
  async history(@CurrentUser() user: User) {
    return await ChatHistory.find({ where: { user: { id: user.id } } });
  }
}
