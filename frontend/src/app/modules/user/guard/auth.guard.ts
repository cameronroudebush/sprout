import { Injectable } from "@angular/core";
import { CanActivate } from "@angular/router";
import { RouteURLs } from "@frontend/modules/routing/models/url";
import { RedirectService } from "@frontend/modules/routing/service/redirect.service";
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
    private redirectService: RedirectService,
  ) {}

  async canActivate() {
    const currentUser = await firstValueFrom(this.store.select(selectCurrentUser));
    // Redirect to login if need be
    if (!currentUser) this.redirectService.redirectTo(RouteURLs.login);
    return currentUser != null;
  }
}
