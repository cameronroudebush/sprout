import { Injectable } from "@angular/core";
import { Router } from "@angular/router";
import { RouteURLs } from "@frontend/modules/routing/models/url";

@Injectable({
  providedIn: "root",
})
export class RouterService {
  constructor(private router: Router) {}

  /** Redirect to the given path */
  redirectTo(path: RouteURLs) {
    this.router.navigate([path]);
  }

  /** Given a route, returns true if it is the current route and false if not */
  isCurrentRoute(route: RouteURLs) {
    return this.currentRoute === `/${route}`;
  }

  get currentRoute() {
    return this.router.url;
  }
}
