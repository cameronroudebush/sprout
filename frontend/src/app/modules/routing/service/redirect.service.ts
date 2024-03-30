import { Injectable } from "@angular/core";
import { Router } from "@angular/router";
import { RouteURLs } from "@frontend/modules/routing/models/url";

@Injectable({
  providedIn: "root",
})
export class RedirectService {
  constructor(private router: Router) {}

  /** Redirect to the given path */
  redirectTo(path: RouteURLs) {
    this.router.navigate([path]);
  }
}
