import { Component, Input, OnInit } from "@angular/core";

/**
 * Generic component that can provide a spinner to be displayed for a component. Normally used as an indicator
 *  that a web request is being made.
 */
@Component({
  selector: "shared-progress",
  templateUrl: "./progress.component.html",
  styleUrls: ["./progress.component.scss"],
})
export class SharedProgressComponent implements OnInit {
  /** If given false, we should display the spinner to show the component is not rendered */
  @Input() ready: boolean = false;

  /** How big in pixels to display the spinner */
  @Input() diameter = 20;

  constructor() {}

  ngOnInit() {}
}
