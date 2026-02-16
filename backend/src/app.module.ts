import { AccountController } from "@backend/account/account.controller";
import { AuthModule } from "@backend/auth/auth.module";
import { CategoryController } from "@backend/category/category.controller";
import { CategoryService } from "@backend/category/category.service";
import { ChatModule } from "@backend/chat/chat.module";
import { ConfigController } from "@backend/config/config.controller";
import { ConfigurationService } from "@backend/config/config.service";
import { Configuration } from "@backend/config/core";
import { CoreController } from "@backend/core/core.controller";
import { ImageProxyController } from "@backend/core/image.proxy.controller";
import { RequestLoggerMiddleware } from "@backend/core/middleware/request.logger.middleware";
import { DatabaseService } from "@backend/database/database.service";
import { HoldingModule } from "@backend/holding/holding.module";
import { JobsService } from "@backend/jobs/jobs.service";
import { NetWorthModule } from "@backend/net-worth/net-worth.module";
import { NotificationModule } from "@backend/notification/notification.module";
import { ProviderModule } from "@backend/providers/provider.module";
import { SSEModule } from "@backend/sse/sse.module";
import { TransactionController } from "@backend/transaction/transaction.controller";
import { TransactionRuleController } from "@backend/transaction/transaction.rule.controller";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { TransactionService } from "@backend/transaction/transaction.service";
import { UserModule } from "@backend/user/user.module";
import { MiddlewareConsumer, Module } from "@nestjs/common";
import { APP_GUARD } from "@nestjs/core";
import { ThrottlerGuard, ThrottlerModule } from "@nestjs/throttler";
import { CashFlowController } from "./cash-flow/cash.flow.controller";
import { CashFlowService } from "./cash-flow/cash.flow.service";

@Module({
  imports: [
    AuthModule,
    UserModule,
    ProviderModule,
    ChatModule,
    HoldingModule,
    SSEModule,
    NotificationModule,
    NetWorthModule,
    ThrottlerModule.forRoot([
      {
        ttl: Configuration.server.rateLimit.ttl,
        limit: Configuration.server.rateLimit.limit,
      },
    ]),
  ],
  controllers: [
    CoreController,
    AccountController,
    TransactionController,
    TransactionRuleController,
    CategoryController,
    ConfigController,
    CashFlowController,
    ImageProxyController,
  ],
  providers: [
    TransactionService,
    TransactionRuleService,
    ConfigurationService,
    JobsService,
    DatabaseService,
    CategoryService,
    CashFlowService,
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
  exports: [],
})
export class AppModule {
  configure(consumer: MiddlewareConsumer): void {
    consumer.apply(RequestLoggerMiddleware).forRoutes(`*path`);
  }
}
