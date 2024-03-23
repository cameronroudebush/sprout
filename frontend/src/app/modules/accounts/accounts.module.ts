import { CommonModule } from "@angular/common";
import { NgModule } from "@angular/core";
import { MaterialModule } from "../material/material.module";
import { AccountsDashboardComponent } from "./dashboard/dashboard.component";

const COMPONENTS = [AccountsDashboardComponent];

@NgModule({
  declarations: COMPONENTS,
  exports: COMPONENTS,
  imports: [CommonModule, MaterialModule],
})
export class AccountsModule {}
