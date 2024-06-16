import { Injectable } from "@angular/core";
import { CanActivate } from "@angular/router";
import { Params } from "@frontend/modules/routing/models/param";
import { RouteURLs } from "@frontend/modules/routing/models/url";
import { RouterService } from "@frontend/modules/routing/service/router.service";
import { UserState } from "@frontend/modules/user/store/user.state";
import { Store } from "@ngrx/store";
import { firstValueFrom } from "rxjs";
import { selectCurrentUser } from "../store/user.selector";

@Injectable({
  providedIn: "root",
})
export class AuthGuard implements CanActivate {
  constructor(
    private store: Store<UserState>,
    private routerService: RouterService,
  ) {}

  async canActivate() {
    const currentUser = await firstValueFrom(this.store.select(selectCurrentUser));
    // Redirect to login if need be
    if (!currentUser) {
      // Set our "last url" param
      await this.routerService.setParam(Params.lastUrl, window.location.pathname);
      await this.routerService.redirectTo(RouteURLs.login);
    }
    return currentUser != null;
  }
}
