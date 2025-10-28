import { AccountController } from "@backend/account/account.controller";
import { CategoryController } from "@backend/category/category.controller";
import { CategoryService } from "@backend/category/category.service";
import { ConfigController } from "@backend/config/config.controller";
import { ConfigurationService } from "@backend/config/config.service";
import { Configuration } from "@backend/config/core";
import { CoreController } from "@backend/core/core.controller";
import { ImageProxyController } from "@backend/core/image.proxy.controller";
import { RequestLoggerMiddleware } from "@backend/core/middleware/request.logger.middleware";
import { NetWorthController } from "@backend/core/net.worth.controller";
import { SetupService } from "@backend/core/setup.service";
import { DatabaseService } from "@backend/database/database.service";
import { HoldingController } from "@backend/holding/holding.controller";
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
import { MiddlewareConsumer, Module } from "@nestjs/common";
import { APP_GUARD } from "@nestjs/core";
import { ThrottlerGuard, ThrottlerModule } from "@nestjs/throttler";
import { CashFlowController } from "./cash-flow/cash.flow.controller";
import { CashFlowService } from "./cash-flow/cash.flow.service";

@Module({
  imports: [
    ThrottlerModule.forRoot([
      {
        ttl: Configuration.server.rateLimit.ttl,
        limit: Configuration.server.rateLimit.limit,
      },
    ]),
  ],
  controllers: [
    CoreController,
    UserController,
    UserConfigController,
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
  ],
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
