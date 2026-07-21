import { DatabaseModule } from "@backend/database/database.module";
import { NotificationModule } from "@backend/notification/notification.module";
import { SSEModule } from "@backend/sse/sse.module";
import { TransactionController } from "@backend/transaction/transaction.controller";
import { TransactionRuleController } from "@backend/transaction/transaction.rule.controller";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { TransactionService } from "@backend/transaction/transaction.service";
import { Module } from "@nestjs/common";

@Module({
  imports: [SSEModule, DatabaseModule, NotificationModule],
  controllers: [TransactionController, TransactionRuleController],
  providers: [TransactionRuleService, TransactionService],
  exports: [TransactionRuleService, TransactionService],
})
export class TransactionModule {}
