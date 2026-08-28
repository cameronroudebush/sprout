import { NetWorthController } from "@backend/net-worth/net-worth.controller";
import { NetWorthService } from "@backend/net-worth/net-worth.service";
import { Module } from "@nestjs/common";

@Module({
  imports: [],
  controllers: [NetWorthController],
  providers: [NetWorthService],
  exports: [NetWorthService],
})
export class NetWorthModule {}
