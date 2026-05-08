import { AccountModule } from "@backend/account/account.module";
import { AuthModule } from "@backend/auth/auth.module";
import { CategoryController } from "@backend/category/category.controller";
import { CategoryService } from "@backend/category/category.service";
import { ChatModule } from "@backend/chat/chat.module";
import { ConfigController } from "@backend/config/config.controller";
import { ConfigurationService } from "@backend/config/config.service";
import { Configuration } from "@backend/config/core";
import { ContextSerializerInterceptor } from "@backend/core/context.serializer";
import { CoreController } from "@backend/core/core.controller";
import { ImageProxyController } from "@backend/core/image.proxy.controller";
import { SproutLogger } from "@backend/core/logger";
import { RequestLoggerMiddleware } from "@backend/core/middleware/request.logger.middleware";
import { DatabaseModule } from "@backend/database/database.module";
import { EmailModule } from "@backend/email/email.module";
import { HoldingModule } from "@backend/holding/holding.module";
import { JobsModule } from "@backend/jobs/jobs.module";
import { NetWorthModule } from "@backend/net-worth/net-worth.module";
import { NotificationModule } from "@backend/notification/notification.module";
import { ProviderModule } from "@backend/providers/provider.module";
import { SSEModule } from "@backend/sse/sse.module";
import { TransactionModule } from "@backend/transaction/transaction.module";
import { UserModule } from "@backend/user/user.module";
import KeyvRedis, { Keyv } from "@keyv/redis";
import { CacheModule } from "@nestjs/cache-manager";
import { MiddlewareConsumer, Module } from "@nestjs/common";
import { APP_GUARD, APP_INTERCEPTOR } from "@nestjs/core";
import { ThrottlerGuard, ThrottlerModule } from "@nestjs/throttler";
import { KeyvCacheableMemory } from "cacheable";
import { CashFlowController } from "./cash-flow/cash.flow.controller";
import { CashFlowService } from "./cash-flow/cash.flow.service";

@Module({
  imports: [
    DatabaseModule,
    AuthModule,
    UserModule,
    ProviderModule,
    ChatModule,
    HoldingModule,
    SSEModule,
    NotificationModule,
    NetWorthModule,
    ProviderModule,
    TransactionModule,
    EmailModule,
    AccountModule,
    ThrottlerModule.forRoot([
      {
        ttl: Configuration.server.rateLimit.ttl,
        limit: Configuration.server.rateLimit.limit,
      },
    ]),
    CacheModule.registerAsync({
      isGlobal: true,
      useFactory: async () => {
        // 1. Always initialize the local memory store (L1 Cache)
        const memoryStore = new Keyv({
          store: new KeyvCacheableMemory({ ttl: 60000, lruSize: 5000 }),
        });

        // Start with only the memory store in our hierarchy
        const stores: any[] = [memoryStore];

        // 2. Conditionally add the Redis store (L2 Cache)
        if (Configuration.server.cache.type === "redis") {
          // Construct the connection string
          const auth = Configuration.cache.password ? `:${Configuration.cache.password}@` : "";
          const redisUrl = `redis://${auth}${Configuration.cache.host}:${Configuration.cache.port}`;

          const redisStore = new KeyvRedis(redisUrl);

          // Push Redis into the array. Keyv reads the array in order.
          stores.push(redisStore);
        }

        return {
          stores: stores,
        };
      },
    }),
    // Always initialize jobs last
    JobsModule,
  ],
  controllers: [CoreController, CategoryController, ConfigController, CashFlowController, ImageProxyController],
  providers: [
    ConfigurationService,
    CategoryService,
    CashFlowService,
    SproutLogger,
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: ContextSerializerInterceptor,
    },
  ],
  exports: [],
})
export class AppModule {
  configure(consumer: MiddlewareConsumer): void {
    consumer.apply(RequestLoggerMiddleware).forRoutes(`*path`);
  }
}
