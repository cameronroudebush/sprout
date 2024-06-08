import { HttpErrorResponse } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { RestBody, User, UserLoginRequest, UserLoginResponse } from "@common";
import { RestService } from "@frontend/modules/communication/service/rest.service";
import { RouteURLs } from "@frontend/modules/routing/models/url";
import { RouterService } from "@frontend/modules/routing/service/router.service";
import { ServiceBase } from "@frontend/modules/shared/service/base";
import { SnackbarService } from "@frontend/modules/shared/service/snackbar.service";
import { UserState } from "@frontend/modules/user/store/user.state";
import { Store } from "@ngrx/store";
import { UserActions } from "../store/user.actions";

@Injectable({
  providedIn: "root",
})
export class UserService extends ServiceBase {
  /** Key for local storage for the cached JWT */
  static readonly CACHED_JWT_KEY = "jwt";
  constructor(
    private store: Store<UserState>,
    private restService: RestService,
    private routerService: RouterService,
    private snackbarService: SnackbarService,
  ) {
    super();
  }

  override async initialize() {}

  /** Centralized function to handle login request and responses */
  private async handleLoginReq(request: { (): Promise<RestBody<UserLoginResponse>> }) {
    try {
      const response = await request();
      const user = User.fromPlain(response.payload.user);
      this.store.dispatch(UserActions.addUser({ user }));
      this.store.dispatch(UserActions.setCurrentUser({ user }));
      this.cachedJWT = response.payload.jwt;
      return user;
    } catch (e) {
      return { isError: true, message: (e as HttpErrorResponse).statusText };
    }
  }

  /** Given some user information, performs a login request */
  async login(username: string, password: string) {
    return await this.handleLoginReq(
      this.restService.post.bind(this.restService, "user.login", UserLoginRequest.fromPlain({ username, password })) as {
        (): Promise<RestBody<UserLoginResponse>>;
      },
    );
  }

  /** Like login but performs the login with a JWT */
  async loginWithJWT(jwt: string) {
    return await this.handleLoginReq(
      this.restService.post.bind(this.restService, "user.loginJWT", UserLoginRequest.fromPlain({ jwt })) as {
        (): Promise<RestBody<UserLoginResponse>>;
      },
    );
  }

  /** Logs out the current user and clears the cached JWT so auto logins don't occur */
  logout() {
    this.cachedJWT = null;
    this.store.dispatch(UserActions.setCurrentUser({ user: undefined }));
    this.routerService.redirectTo(RouteURLs.login);
    this.snackbarService.open("Logout successful");
  }

  get cachedJWT() {
    return localStorage.getItem(UserService.CACHED_JWT_KEY);
  }

  set cachedJWT(jwt: string | null) {
    if (jwt == null) localStorage.removeItem(UserService.CACHED_JWT_KEY);
    else localStorage.setItem(UserService.CACHED_JWT_KEY, jwt);
  }
}
