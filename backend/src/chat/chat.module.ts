import { ChatController } from "@backend/chat/chat.controller";
import { ChatPromptService } from "@backend/chat/chat.prompt.service";
import { ChatService } from "@backend/chat/chat.service";
import { HoldingModule } from "@backend/holding/holding.module";
import { SSEModule } from "@backend/sse/sse.module";
import { TransactionModule } from "@backend/transaction/transaction.module";
import { Module } from "@nestjs/common";

@Module({
  imports: [HoldingModule, SSEModule, TransactionModule],
  controllers: [ChatController],
  providers: [ChatService, ChatPromptService],
  exports: [ChatService],
})
export class ChatModule {}
