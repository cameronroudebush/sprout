import { Component } from "@angular/core";
import { RouteURLs } from "@frontend/modules/routing/models/url";
import { RouterService } from "@frontend/modules/routing/service/router.service";

@Component({
  selector: "app-root",
  templateUrl: "core.component.html",
  styleUrls: ["core.component.scss"],
})
export class AppComponent {
  constructor(private routerService: RouterService) {}

  /** Returns if the navbar should be rendered */
  get shouldRenderNavbar() {
    return !this.routerService.isCurrentRoute(RouteURLs.login);
  }
}
