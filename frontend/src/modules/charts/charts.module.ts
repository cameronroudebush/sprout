import { CommonModule } from "@angular/common";
import { NgModule } from "@angular/core";
import { LineChartComponent } from "./types/line";

const COMPONENTS = [LineChartComponent];

@NgModule({
  declarations: COMPONENTS,
  exports: COMPONENTS,
  imports: [CommonModule],
})
export class ChartsModule {}
