import { Component, OnInit } from "@angular/core";
import Chart from "chart.js/auto";

@Component({
  selector: "chart-base",
  templateUrl: "./base.component.html",
  styleUrls: ["./base.component.scss"],
})
export class ChartBaseComponent implements OnInit {
  /** The overarching chart element we are currently rendering */
  chart: Chart | undefined;

  constructor() {}

  ngOnInit() {
    this.initialize();
  }

  /** Returns the chart element from the DOM */
  get chartElement() {
    return document.getElementById("chart") as HTMLCanvasElement | undefined;
  }

  /** Initializes our chart with information given */
  initialize() {
    this.chart = new Chart(this.chartElement!, {
      type: "bar",

      data: {
        labels: ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],
        datasets: [
          {
            label: "# of Votes",
            data: [12, 19, 3, 5, 2, 3],
            borderWidth: 1,
          },
        ],
      },
      options: {
        responsive: true,
        // scales: {
        //   y: {
        //     beginAtZero: true,
        //   },
        // },
      },
    });
  }
}
