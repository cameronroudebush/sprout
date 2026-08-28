import { ChatModule } from "@backend/chat/chat.module";
import { NotificationModule } from "@backend/notification/notification.module";
import { ProviderBase } from "@backend/providers/base/core";
import { ProviderSyncService } from "@backend/providers/base/sync.service";
import { PostSyncProcessingJob } from "@backend/providers/jobs/post-sync";
import { ProviderSyncJob } from "@backend/providers/jobs/sync";
import { PROVIDER_LIST_TOKEN } from "@backend/providers/model/constants";
import { PlaidProviderController } from "@backend/providers/plaid/plaid.controller";
import { PlaidProviderService } from "@backend/providers/plaid/plaid.provider.service";
import { PlaidWebhookController } from "@backend/providers/plaid/plaid.webhook.controller";
import { BaseProviderController } from "@backend/providers/provider.controller";
import { ProviderService } from "@backend/providers/provider.service";
import { SimpleFinProviderController } from "@backend/providers/simple-fin/simple-fin.controller";
import { SimpleFINProviderService } from "@backend/providers/simple-fin/simple-fin.provider.service";
import { SnapTradeProviderController } from "@backend/providers/snap-trade/snap-trade.controller";
import { SnapTradeProviderService } from "@backend/providers/snap-trade/snap-trade.provider.service";
import { SnapTradeWebHookController } from "@backend/providers/snap-trade/snap-trade.webhook.controller";
import { ZillowProviderController } from "@backend/providers/zillow/zillow.controller";
import { ZillowProviderService } from "@backend/providers/zillow/zillow.provider.service";
import { SSEModule } from "@backend/sse/sse.module";
import { TransactionModule } from "@backend/transaction/transaction.module";
import { HttpModule } from "@nestjs/axios";
import { FactoryProvider, Module } from "@nestjs/common";
import { DiscoveryModule } from "@nestjs/core";

const ALL_PROVIDERS = [SimpleFINProviderService, PlaidProviderService, ZillowProviderService, SnapTradeProviderService];

// Factory that creates a ProviderSyncJob for each active provider
export const ProviderSyncJobsProvider: FactoryProvider = {
  provide: "PROVIDER_SYNC_JOBS",
  useFactory: (providers: ProviderBase[], syncService: ProviderSyncService) => {
    return providers.map((provider) => new ProviderSyncJob(provider, syncService));
  },
  inject: [PROVIDER_LIST_TOKEN, ProviderSyncService],
};

@Module({
  imports: [DiscoveryModule, HttpModule, SSEModule, TransactionModule, NotificationModule, ChatModule],
  controllers: [
    BaseProviderController,
    // SimpleFIN
    SimpleFinProviderController,
    // Zillow
    ZillowProviderController,
    // Plaid
    PlaidProviderController,
    PlaidWebhookController,
    // SnapTrade
    SnapTradeProviderController,
    SnapTradeWebHookController,
  ],
  providers: [
    ProviderService,
    ProviderSyncService,
    ProviderSyncJobsProvider,
    PostSyncProcessingJob,
    ...ALL_PROVIDERS,
    {
      provide: PROVIDER_LIST_TOKEN,
      useFactory: (...instances) => instances,
      inject: ALL_PROVIDERS,
    },
  ],
  exports: [ProviderSyncService, PROVIDER_LIST_TOKEN, ...ALL_PROVIDERS],
})
export class ProviderModule {}
