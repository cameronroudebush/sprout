import { HoldingController } from "@backend/holding/holding.controller";
import { HoldingService } from "@backend/holding/holding.service";
import { NetWorthModule } from "@backend/net-worth/net-worth.module";
import { Module } from "@nestjs/common";

@Module({
  imports: [NetWorthModule],
  controllers: [HoldingController],
  providers: [HoldingService],
  exports: [HoldingService],
})
export class HoldingModule {}
