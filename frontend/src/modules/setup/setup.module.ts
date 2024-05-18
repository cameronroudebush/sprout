import { NgModule } from "@angular/core";
import { MaterialModule } from "@frontend/modules/material/material.module";
import { HomeSetupComponent } from "./component/home/home.component";
import { AdminSetupComponent } from "./component/home/steps/admin/admin.component";
import { WelcomeSetupComponent } from "./component/home/steps/welcome/welcome.component";
import { SetupService } from "./service/setup.service";

const COMPONENTS = [HomeSetupComponent, AdminSetupComponent, WelcomeSetupComponent];

/** This module controls the initial setup when you start a new instance of sprout for the first time */
@NgModule({
  declarations: COMPONENTS,
  exports: COMPONENTS,
  imports: [MaterialModule],
  providers: [SetupService],
})
export class SetupModule {}
