import { Component, OnInit } from "@angular/core";
import { Utility } from "@common";

@Component({
  selector: "app-dashboard",
  templateUrl: "./dashboard.component.html",
  styleUrls: ["./dashboard.component.scss"],
})
export class DashboardComponent implements OnInit {
  funFact = Utility.randomFromArray(FUN_FACTS);
  constructor() {}

  ngOnInit() {}
}

/** Fun facts related to personal finance to display */
export const FUN_FACTS = [
  "Even saving a small amount towards retirement early on can make a big difference. The power of time and compound interest can turn a trickle into a stream.",
  "Financial literacy is an important life skill. There are many free resources available to learn about budgeting, saving, and investing.",
  "Taking control of your finances can be empowering. Setting and achieving financial goals can boost your confidence and well-being.",
  'Even small amounts of money saved early can grow significantly over time thanks to compound interest.  Albert Einstein called it "the eighth wonder of the world."',
];
