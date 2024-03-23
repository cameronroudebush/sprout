import { Component } from "@angular/core";
import { APP_ROUTES } from "@frontend/modules/routing/models/config";

@Component({
  selector: "routing-tabs",
  templateUrl: "tabs.html",
  styleUrls: ["tabs.scss"],
})
export class RoutingTabs {
  constructor() {}

  get tabs() {
    return APP_ROUTES;
  }
}
