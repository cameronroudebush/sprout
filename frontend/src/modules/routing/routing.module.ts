import { NgModule } from "@angular/core";
import { RouterModule } from "@angular/router";
import { MaterialModule } from "@frontend/modules/material/material.module";
import { NavbarComponent } from "./component/navbar/navbar.component";
import { APP_ROUTES } from "./models/config";
import { RouterService } from "./service/router.service";

const COMPONENTS = [NavbarComponent];

/** This module controls all routing capabilities for the app across modules */
@NgModule({
  declarations: COMPONENTS,
  imports: [RouterModule.forRoot(APP_ROUTES), MaterialModule],
  providers: [RouterService],
  exports: COMPONENTS,
})
export class RoutingModule {}
