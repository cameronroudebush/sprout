import { ProviderService } from "@backend/providers/provider.service";
import { HttpModule } from "@nestjs/axios";
import { Module } from "@nestjs/common";

@Module({
  imports: [HttpModule],
  controllers: [],
  providers: [ProviderService],
  exports: [ProviderService],
})
export class ProviderModule {}
