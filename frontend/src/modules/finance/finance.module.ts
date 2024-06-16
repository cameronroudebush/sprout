import { CommonModule } from "@angular/common";
import { NgModule } from "@angular/core";
import { ChartsModule } from "@frontend/modules/charts/charts.module";
import { SharedModule } from "@frontend/modules/shared/shared.module";
import { StoreModule } from "@ngrx/store";
import { MaterialModule } from "../material/material.module";
import { NetWorthChartComponent } from "./component/charts/net-worth/net-worth.component";
import { TransactionComponent } from "./component/transaction/transaction.component";
import { TransactionService } from "./service/transaction.service";
import { financeReducer } from "./store/finance.reducer";
import { FINANCE_NGRX_KEY } from "./store/finance.state";

const COMPONENTS = [TransactionComponent, NetWorthChartComponent];

@NgModule({
  declarations: COMPONENTS,
  exports: COMPONENTS,
  imports: [CommonModule, MaterialModule, StoreModule.forFeature(FINANCE_NGRX_KEY, financeReducer), SharedModule, ChartsModule],
  providers: [TransactionService],
})
export class FinanceModule {}
