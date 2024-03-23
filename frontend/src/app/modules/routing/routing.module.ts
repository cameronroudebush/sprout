import { NgModule } from "@angular/core";
import { RouterModule } from "@angular/router";
import { AccountsModule } from "@frontend/modules/accounts/accounts.module";
import { MaterialModule } from "@frontend/modules/material/material.module";
import { APP_ROUTES } from "./models/config";
import { RoutingTabs } from "./tabs/tabs";

const COMPONENTS = [RoutingTabs];

/** This module controls all routing capabilities for the app across modules */
@NgModule({
  declarations: COMPONENTS,
  imports: [RouterModule.forRoot(APP_ROUTES), MaterialModule, AccountsModule],
  exports: COMPONENTS,
})
export class RoutingModule {}
