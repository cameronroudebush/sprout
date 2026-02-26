import { HoldingController } from "@backend/holding/holding.controller";
import { HoldingService } from "@backend/holding/holding.service";
import { NetWorthModule } from "@backend/net-worth/net-worth.module";
import { CacheModule } from "@nestjs/cache-manager";
import { Module } from "@nestjs/common";

@Module({
  imports: [NetWorthModule, CacheModule.register()],
  controllers: [HoldingController],
  providers: [HoldingService],
  exports: [HoldingService],
})
export class HoldingModule {}
