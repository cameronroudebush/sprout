import { BudgetController } from "@backend/budget/budget.controller";
import { BudgetService } from "@backend/budget/budget.service";
import { CashFlowModule } from "@backend/cash-flow/cash.flow.module";
import { Module } from "@nestjs/common";

@Module({
  imports: [CashFlowModule],
  controllers: [BudgetController],
  providers: [BudgetService],
  exports: [BudgetService],
})
export class BudgetModule {}
