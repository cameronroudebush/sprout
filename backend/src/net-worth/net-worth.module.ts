import { NetWorthController } from "@backend/net-worth/net-worth.controller";
import { NetWorthService } from "@backend/net-worth/net-worth.service";
import { ProviderModule } from "@backend/providers/provider.module";
import { Module } from "@nestjs/common";

@Module({
  imports: [ProviderModule],
  controllers: [NetWorthController],
  providers: [NetWorthService],
  exports: [NetWorthService],
})
export class NetWorthModule {}
