import { HoldingController } from "@backend/holding/holding.controller";
import { HoldingService } from "@backend/holding/holding.service";
import { Module } from "@nestjs/common";

@Module({
  imports: [],
  controllers: [HoldingController],
  providers: [HoldingService],
  exports: [HoldingService],
})
export class HoldingModule {}
