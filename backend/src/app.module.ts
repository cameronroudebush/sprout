import { AccountController } from "@backend/account/account.controller";
import { AccountService } from "@backend/account/account.service";
import { ConfigurationService } from "@backend/config/config.service";
import { DatabaseService } from "@backend/database/database.service";
import { JobsService } from "@backend/jobs/jobs.service";
import { ProviderService } from "@backend/providers/provider.service";
import { TransactionController } from "@backend/transaction/transaction.controller";
import { TransactionService } from "@backend/transaction/transaction.service";
import { UserController } from "@backend/user/user.controller";
import { UserService } from "@backend/user/user.service";
import { Module } from "@nestjs/common";
import { ThrottlerModule } from "@nestjs/throttler";

@Module({
  imports: [
    ThrottlerModule.forRoot([
      {
        ttl: 60000, // 1 minute
        limit: 100, // 100 requests
      },
    ]),
  ],
  controllers: [UserController, AccountController, TransactionController],
  providers: [UserService, AccountService, TransactionService, ConfigurationService, ProviderService, JobsService, DatabaseService],
  exports: [],
})
export class AppModule {}
