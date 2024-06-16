import { Injectable } from "@angular/core";
import { Router } from "@angular/router";
import { APP_ROUTES } from "@frontend/modules/routing/models/config";
import { RouteURLs } from "@frontend/modules/routing/models/url";
import { ServiceBase } from "@frontend/modules/shared/service/base";
import { flattenDeep } from "lodash";
import { Params } from "../models/param";

@Injectable({
  providedIn: "root",
})
export class RouterService extends ServiceBase {
  constructor(private router: Router) {
    super();
  }

  /** Redirect to the given path. By default maintains params. */
  async redirectTo(path: RouteURLs, params?: { [val: string]: string | undefined }) {
    const currentParams = this.currentParams;
    await this.router.navigate([path], { queryParams: { ...currentParams, ...params } });
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

  /** If the given string is a valid route, returns it. If it is not, returns the default */
  isValidGetDefault(route: string | undefined) {
    route = route?.replace("/", "");
    const match = Object.values(RouteURLs).find((x) => x === route);
    return match ?? RouteURLs.default_route;
  }

  get currentParams() {
    const params: { [val: string]: string } = {};
    new URLSearchParams(window.location.search).forEach((val, key) => (params[key] = val));
    return params;
  }

  get currentRoute() {
    return this.router.url;
  }

  /** Returns the current param if set or undefined if not */
  getParam(param: Params): string | undefined {
    return this.currentParams[param];
  }

  /** Sets the given query param without redirecting */
  async setParam(param: Params, value: string) {
    await this.router.navigate([this.currentRoute], { queryParams: { [param]: value } });
  }
}
