import { NgModule } from "@angular/core";
import { RouterModule } from "@angular/router";
import { MaterialModule } from "@frontend/modules/material/material.module";
import { APP_ROUTES } from "./models/config";
import { RouterService } from "./service/router.service";

/** This module controls all routing capabilities for the app across modules */
@NgModule({
  imports: [RouterModule.forRoot(APP_ROUTES), MaterialModule],
  providers: [RouterService],
})
export class RoutingModule {}
