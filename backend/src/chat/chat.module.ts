import { ChatController } from "@backend/chat/chat.controller";
import { ChatService } from "@backend/chat/chat.service";
import { HoldingModule } from "@backend/holding/holding.module";
import { SSEModule } from "@backend/sse/sse.module";
import { Module } from "@nestjs/common";

@Module({
  imports: [HoldingModule, SSEModule],
  controllers: [ChatController],
  providers: [ChatService],
  exports: [ChatService],
})
export class ChatModule {}
