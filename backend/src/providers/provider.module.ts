import { PROVIDER_LIST_TOKEN } from "@backend/providers/model/constants";
import { PlaidProviderController } from "@backend/providers/plaid/plaid.controller";
import { PlaidProviderService } from "@backend/providers/plaid/plaid.provider.service";
import { BaseProviderController } from "@backend/providers/provider.controller";
import { SimpleFinProviderController } from "@backend/providers/simple-fin/simple-fin.controller";
import { SimpleFINProviderService } from "@backend/providers/simple-fin/simple-fin.provider.service";
import { ZillowProviderController } from "@backend/providers/zillow/zillow.controller";
import { ZillowProviderService } from "@backend/providers/zillow/zillow.provider.service";
import { SSEModule } from "@backend/sse/sse.module";
import { TransactionModule } from "@backend/transaction/transaction.module";
import { HttpModule } from "@nestjs/axios";
import { Module } from "@nestjs/common";

const ALL_PROVIDERS = [SimpleFINProviderService, ZillowProviderService, PlaidProviderService];

@Module({
  imports: [HttpModule, SSEModule, TransactionModule],
  controllers: [BaseProviderController, SimpleFinProviderController, ZillowProviderController, PlaidProviderController],
  providers: [
    ...ALL_PROVIDERS,
    {
      provide: PROVIDER_LIST_TOKEN,
      useFactory: (...instances) => instances,
      inject: ALL_PROVIDERS,
    },
  ],
  exports: [PROVIDER_LIST_TOKEN, ...ALL_PROVIDERS],
})
export class ProviderModule {}
