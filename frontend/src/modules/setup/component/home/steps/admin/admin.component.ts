import { Component, Input, OnInit } from "@angular/core";

@Component({
  selector: "setup-admin",
  templateUrl: "./admin.component.html",
  styleUrls: ["./admin.component.scss"],
})
export class AdminSetupComponent implements OnInit {
  /** The on click to fire when to go to the next page */
  @Input() click!: Function;
  constructor() {}

  ngOnInit() {}
}
