import { Component, Input, OnInit } from "@angular/core";

@Component({
  selector: "setup-complete",
  templateUrl: "./complete.component.html",
  styleUrls: ["./complete.component.scss"],
})
export class CompleteSetupComponent implements OnInit {
  /** The on click to fire when to go to the next page */
  @Input() click!: Function;

  constructor() {}

  ngOnInit() {}
}
