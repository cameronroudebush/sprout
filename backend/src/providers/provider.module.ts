import { ProviderService } from "@backend/providers/provider.service";
import { Module } from "@nestjs/common";

@Module({
  imports: [],
  controllers: [],
  providers: [ProviderService],
  exports: [ProviderService],
})
export class ProviderModule {}
