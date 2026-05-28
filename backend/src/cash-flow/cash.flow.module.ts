import { CashFlowController } from "@backend/cash-flow/cash.flow.controller";
import { CashFlowService } from "@backend/cash-flow/cash.flow.service";
import { DatabaseModule } from "@backend/database/database.module";
import { JobsModule } from "@backend/jobs/jobs.module";
import { SSEModule } from "@backend/sse/sse.module";
import { Module } from "@nestjs/common";

@Module({
  imports: [SSEModule, JobsModule, DatabaseModule],
  controllers: [CashFlowController],
  providers: [CashFlowService],
  exports: [CashFlowService],
})
export class CashFlowModule {}
