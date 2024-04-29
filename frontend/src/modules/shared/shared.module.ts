import { CommonModule } from "@angular/common";
import { APP_INITIALIZER, NgModule } from "@angular/core";
import { MaterialModule } from "@frontend/modules/material/material.module";
import { RoutingModule } from "@frontend/modules/routing/routing.module";
import { SharedProgressComponent } from "./component/progress/progress.component";
import { SharedTableComponent } from "./component/table/table.component";
import { ServiceManager } from "./service/manager";
import { SnackbarService } from "./service/snackbar.service";

const COMPONENTS = [SharedProgressComponent, SharedTableComponent];

@NgModule({
  declarations: COMPONENTS,
  imports: [CommonModule, MaterialModule, RoutingModule],
  providers: [
    SnackbarService,
    {
      provide: APP_INITIALIZER,
      useFactory: (manager: ServiceManager) =>
        function () {
          manager.callFnc("initialize");
        },
      deps: [ServiceManager],
      multi: true,
    },
  ],
  exports: COMPONENTS,
})
export class SharedModule {}
