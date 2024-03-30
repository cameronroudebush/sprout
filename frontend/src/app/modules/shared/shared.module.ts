import { CommonModule } from "@angular/common";
import { NgModule } from "@angular/core";
import { MaterialModule } from "@frontend/modules/material/material.module";
import { RoutingModule } from "@frontend/modules/routing/routing.module";
import { SnackbarService } from "./service/snackbar.service";
import { SharedProgressComponent } from "./shared-progress/shared-progress.component";

const COMPONENTS = [SharedProgressComponent];

@NgModule({
  declarations: COMPONENTS,
  imports: [CommonModule, MaterialModule, RoutingModule],
  providers: [SnackbarService],
  exports: COMPONENTS,
})
export class SharedModule {}
