import { CommonModule } from "@angular/common";
import { NgModule } from "@angular/core";
import { ChartBaseComponent } from "./base/base.component";

const COMPONENTS = [ChartBaseComponent];

@NgModule({
  declarations: COMPONENTS,
  exports: COMPONENTS,
  imports: [CommonModule],
})
export class ChartsModule {}
