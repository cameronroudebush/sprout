import { Component, OnInit } from "@angular/core";
import Chart, { ChartDataset, ChartOptions, ChartType, ChartTypeRegistry, CoreChartOptions, DefaultDataPoint } from "chart.js/auto";

@Component({
  selector: "chart-base",
  templateUrl: "./base.component.html",
  styleUrls: ["./base.component.scss"],
})
export abstract class ChartBaseComponent<InternalChartType extends ChartType, DataType = DefaultDataPoint<InternalChartType>> implements OnInit {
  /** The overarching chart element we are currently rendering */
  chart: Chart<InternalChartType> | undefined;
  abstract chartType: keyof ChartTypeRegistry;

  constructor() {}

  ngOnInit() {
    this.initialize();
  }

  /** Returns the chart element from the DOM */
  get chartElement() {
    return document.getElementById("chart") as HTMLCanvasElement | undefined;
  }

  /** Returns the string array of labels for our data sets */
  abstract get labels(): string[];

  /** Returns the data we intend to use to populate our chart */
  abstract get data(): ChartDataset<InternalChartType, DataType>[];

  /** Returns the default chart options we are applying */
  get options() {
    return { responsive: true, maintainAspectRatio: false } as CoreChartOptions<InternalChartType> as ChartOptions<InternalChartType>;
  }

  /** Initializes our chart with information given */
  private initialize() {
    this.chart = new Chart<InternalChartType>(this.chartElement!, {
      type: this.chartType as any,
      data: {
        labels: this.labels,
        datasets: this.data as any,
      },
      options: this.options,
    });
  }
}
