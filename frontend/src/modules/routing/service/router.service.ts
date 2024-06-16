import { Injectable } from "@angular/core";
import { Router } from "@angular/router";
import { APP_ROUTES } from "@frontend/modules/routing/models/config";
import { RouteURLs } from "@frontend/modules/routing/models/url";
import { ServiceBase } from "@frontend/modules/shared/service/base";
import { flattenDeep } from "lodash";

@Injectable({
  providedIn: "root",
})
export class RouterService extends ServiceBase {
  constructor(private router: Router) {
    super();

    console.log(window.location);
  }

  /** Redirect to the given path */
  redirectTo(path: RouteURLs) {
    this.router.navigate([path]);
  }

  /** Given a route, returns true if it is the current route and false if not */
  isCurrentRoute(route: RouteURLs) {
    return this.currentRoute === `/${route}`;
  }

  /** Returns the configuration for our given URL */
  getCurrentRouteConfig() {
    const currentRoute = this.currentRoute.slice(1);
    // Flatten routes
    const routes = flattenDeep(APP_ROUTES);
    return routes.find((x) => x.path === currentRoute);
  }

  get currentRoute() {
    return this.router.url;
  }
}
