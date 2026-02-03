import { AccountController } from "@backend/account/account.controller";
import { AuthModule } from "@backend/auth/auth.module";
import { CategoryController } from "@backend/category/category.controller";
import { CategoryService } from "@backend/category/category.service";
import { ConfigController } from "@backend/config/config.controller";
import { ConfigurationService } from "@backend/config/config.service";
import { Configuration } from "@backend/config/core";
import { CoreController } from "@backend/core/core.controller";
import { ImageProxyController } from "@backend/core/image.proxy.controller";
import { RequestLoggerMiddleware } from "@backend/core/middleware/request.logger.middleware";
import { NetWorthController } from "@backend/core/net.worth.controller";
import { DatabaseService } from "@backend/database/database.service";
import { HoldingController } from "@backend/holding/holding.controller";
import { JobsService } from "@backend/jobs/jobs.service";
import { NotificationController } from "@backend/notification/notification.controller";
import { NotificationService } from "@backend/notification/notification.service";
import { ProviderModule } from "@backend/providers/provider.module";
import { SSEController } from "@backend/sse/sse.controller";
import { SSEService } from "@backend/sse/sse.service";
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
    SSEController,
    CategoryController,
    ConfigController,
    HoldingController,
    NetWorthController,
    CashFlowController,
    ImageProxyController,
    NotificationController,
  ],
  providers: [
    TransactionService,
    TransactionRuleService,
    ConfigurationService,
    JobsService,
    DatabaseService,
    SSEService,
    CategoryService,
    CashFlowService,
    NotificationService,
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
