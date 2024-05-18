import { Component, Input, OnInit } from "@angular/core";

@Component({
  selector: "setup-welcome",
  templateUrl: "./welcome.component.html",
  styleUrls: ["./welcome.component.scss"],
})
export class WelcomeSetupComponent implements OnInit {
  /** The on click to fire when to go to the next page */
  @Input() click!: Function;

  constructor() {}

  ngOnInit() {}
}
