import { Component } from "@angular/core";
import { ChartBaseComponent } from "@frontend/modules/charts/base/base.component";
import { ChartTypeRegistry } from "chart.js/auto";

@Component({
  selector: "chart-line",
  templateUrl: "../base/base.component.html",
  styleUrls: ["../base/base.component.scss"],
})
export class LineChartComponent extends ChartBaseComponent<"line"> {
  override chartType: keyof ChartTypeRegistry = "line";

  /** Returns the string array of labels for our data sets */
  get labels() {
    return ["1", "2", "3", "4", "5", "6", "7"];
  }

  /** Returns the data we intend to use to populate our chart */
  get data() {
    return [
      {
        label: "My First Dataset",
        data: [65, 59, 80, 81, 56, 55, 40],
        fill: false,
        borderColor: "rgb(75, 192, 192)",
        tension: 0.1,
      },
    ];
  }
}
