import { SimpleFinProviderController } from "@backend/providers/simple-fin/simple-fin.controller";
import { SimpleFINProviderService } from "@backend/providers/simple-fin/simple-fin.provider.service";
import { ZillowProviderController } from "@backend/providers/zillow/zillow.controller";
import { ZillowProviderService } from "@backend/providers/zillow/zillow.provider.service";
import { SSEModule } from "@backend/sse/sse.module";
import { TransactionModule } from "@backend/transaction/transaction.module";
import { HttpModule } from "@nestjs/axios";
import { Module } from "@nestjs/common";

/** Token for grabbing the list of providers */
export const PROVIDER_LIST_TOKEN = "PROVIDER_LIST_TOKEN";

const ALL_PROVIDERS = [SimpleFINProviderService, ZillowProviderService];

@Module({
  imports: [HttpModule, SSEModule, TransactionModule],
  controllers: [SimpleFinProviderController, ZillowProviderController],
  providers: [
    SimpleFINProviderService,
    ZillowProviderService,
    {
      provide: PROVIDER_LIST_TOKEN,
      useFactory: (...instances) => instances,
      inject: ALL_PROVIDERS,
    },
  ],
  exports: [PROVIDER_LIST_TOKEN, ...ALL_PROVIDERS],
})
export class ProviderModule {}
