import { AccountController } from "@backend/account/account.controller";
import { ConfigurationService } from "@backend/config/config.service";
import { SetupService } from "@backend/core/setup.service";
import { DatabaseService } from "@backend/database/database.service";
import { JobsService } from "@backend/jobs/jobs.service";
import { ProviderService } from "@backend/providers/provider.service";
import { SSEController } from "@backend/sse/sse.controler";
import { SSEService } from "@backend/sse/sse.service";
import { TransactionController } from "@backend/transaction/transaction.controller";
import { TransactionRuleController } from "@backend/transaction/transaction.rule.controller";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { TransactionService } from "@backend/transaction/transaction.service";
import { UserConfigController } from "@backend/user/user.config.controller";
import { UserController } from "@backend/user/user.controller";
import { UserService } from "@backend/user/user.service";
import { Module } from "@nestjs/common";
import { ThrottlerModule } from "@nestjs/throttler";

@Module({
  imports: [
    // TODO: This should probably be configurable
    ThrottlerModule.forRoot([
      {
        ttl: 60000, // 1 minute
        limit: 1000, // 1000 requests
      },
    ]),
  ],
  controllers: [UserController, UserConfigController, AccountController, TransactionController, TransactionRuleController, SSEController],
  providers: [
    UserService,
    TransactionService,
    TransactionRuleService,
    ConfigurationService,
    ProviderService,
    JobsService,
    DatabaseService,
    SetupService,
    SSEService,
  ],
  exports: [],
})
export class AppModule {}
