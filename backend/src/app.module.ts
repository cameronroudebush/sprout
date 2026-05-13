import { AccountModule } from "@backend/account/account.module";
import { AuthModule } from "@backend/auth/auth.module";
import { CategoryController } from "@backend/category/category.controller";
import { CategoryService } from "@backend/category/category.service";
import { ChatModule } from "@backend/chat/chat.module";
import { ConfigurationModule } from "@backend/config/config.module";
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
    ConfigurationModule,
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
        const logger = new SproutLogger("cache", { logLevels: ["verbose"] });
        // Always initialize the local memory store (L1 Cache)
        const memoryStore = new Keyv({
          store: new KeyvCacheableMemory({}),
        });

        // Start with only the memory store in our hierarchy
        const stores: any[] = [memoryStore];

        // Conditionally add the L2 cache
        if (Configuration.server.cache.type === "redis") {
          logger.log(`L2 cache is enabled. Connecting...`);
          Configuration.server.cache.redis.validate();
          const auth = Configuration.server.cache.redis.password ? `:${Configuration.server.cache.redis.password}@` : "";
          const redisUrl = `redis://${auth}${Configuration.server.cache.redis.host}:${Configuration.server.cache.redis.port}`;
          const redisStore = new KeyvRedis(redisUrl);
          // Check if we can connect
          const timeout = 5000; // 5 seconds
          const connectionTask = async () => {
            if (!redisStore.client.isOpen) await redisStore.client.connect();
            await redisStore.client.ping();
          };
          const timeoutTask = new Promise((_, reject) => setTimeout(() => reject(new Error("Redis connection timed out")), timeout));
          try {
            // Race the connection against the timer
            await Promise.race([connectionTask(), timeoutTask]);
            logger.log(`L2 cache connected successfully!`);
            stores.push(redisStore);
          } catch (error) {
            logger.error(`L2 cache failed to connect: ${error}. Falling back to L1 only.`);
          }
        }

        return {
          stores: stores,
        };
      },
    }),
    // Always initialize jobs last
    JobsModule,
  ],
  controllers: [CoreController, CategoryController, CashFlowController, ImageProxyController],
  providers: [
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
