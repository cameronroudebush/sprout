import { NgModule } from "@angular/core";
import { RouterModule } from "@angular/router";
import { AccountsModule } from "@frontend/modules/accounts/accounts.module";
import { MaterialModule } from "@frontend/modules/material/material.module";
import { APP_ROUTES } from "./models/config";
import { NavbarComponent } from "./navbar/navbar.component";
import { RouterService } from "./service/router.service";

const COMPONENTS = [NavbarComponent];

/** This module controls all routing capabilities for the app across modules */
@NgModule({
  declarations: COMPONENTS,
  imports: [RouterModule.forRoot(APP_ROUTES), MaterialModule, AccountsModule],
  providers: [RouterService],
  exports: COMPONENTS,
})
export class RoutingModule {}
