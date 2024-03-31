import { CommonModule } from "@angular/common";
import { NgModule } from "@angular/core";
import { SharedModule } from "@frontend/modules/shared/shared.module";
import { StoreModule } from "@ngrx/store";
import { MaterialModule } from "../material/material.module";
import { AccountsDashboardComponent } from "./dashboard/dashboard.component";
import { TransactionService } from "./service/transaction.service";
import { financeReducer } from "./store/finance.reducer";
import { FINANCE_NGRX_KEY } from "./store/finance.state";
import { TransactionComponent } from "./transaction/transaction.component";

const COMPONENTS = [AccountsDashboardComponent, TransactionComponent];

@NgModule({
  declarations: COMPONENTS,
  exports: COMPONENTS,
  imports: [CommonModule, MaterialModule, StoreModule.forFeature(FINANCE_NGRX_KEY, financeReducer), SharedModule],
  providers: [TransactionService],
})
export class FinanceModule {}
