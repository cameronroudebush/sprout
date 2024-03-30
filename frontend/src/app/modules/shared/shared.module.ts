import { CommonModule } from "@angular/common";
import { NgModule } from "@angular/core";
import { MaterialModule } from "@frontend/modules/material/material.module";
import { SnackbarService } from "./service/snackbar.service";

@NgModule({
  declarations: [],
  imports: [CommonModule, MaterialModule],
  providers: [SnackbarService],
  bootstrap: [],
})
export class SharedModule {}
