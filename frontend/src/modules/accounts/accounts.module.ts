import { NgModule } from "@angular/core";
import { AccountsDashboardComponent } from "@frontend/modules/accounts/component/dashboard/dashboard.component";
import { AccountsService } from "@frontend/modules/accounts/service/accounts.service";
import { MaterialModule } from "@frontend/modules/material/material.module";
import { StoreModule } from "@ngrx/store";
import { accountReducer } from "./store/account.reducer";
import { ACCOUNT_NGRX_KEY } from "./store/account.state";

const COMPONENTS = [AccountsDashboardComponent];

/** This module controls all the accounts display and capability */
@NgModule({
  declarations: COMPONENTS,
  exports: COMPONENTS,
  imports: [MaterialModule, StoreModule.forFeature(ACCOUNT_NGRX_KEY, accountReducer)],
  providers: [AccountsService],
})
export class AccountsModule {}
