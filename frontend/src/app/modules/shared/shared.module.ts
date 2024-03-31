import { CommonModule } from "@angular/common";
import { NgModule } from "@angular/core";
import { MaterialModule } from "@frontend/modules/material/material.module";
import { RoutingModule } from "@frontend/modules/routing/routing.module";
import { SharedProgressComponent } from "./component/shared-progress/shared-progress.component";
import { SharedTableComponent } from "./component/shared-table/shared-table.component";
import { SnackbarService } from "./service/snackbar.service";

const COMPONENTS = [SharedProgressComponent, SharedTableComponent];

@NgModule({
  declarations: COMPONENTS,
  imports: [CommonModule, MaterialModule, RoutingModule],
  providers: [SnackbarService],
  exports: COMPONENTS,
})
export class SharedModule {}
