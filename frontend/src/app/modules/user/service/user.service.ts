import { HttpErrorResponse } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { RestBody, User, UserLoginRequest, UserLoginResponse } from "@common";
import { RestService } from "@frontend/modules/communication/service/rest.service";
import { UserState } from "@frontend/modules/user/store/user.state";
import { Store } from "@ngrx/store";
import { UserActions } from "../store/user.actions";

@Injectable({
  providedIn: "root",
})
export class UserService {
  /** Key for local storage for the cached JWT */
  static readonly CACHED_JWT_KEY = "jwt";
  constructor(
    private store: Store<UserState>,
    private restService: RestService,
  ) {}

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
      return { isError: true, message: (e as HttpErrorResponse).error };
    }
  }

  /** Given some user information, performs a login request */
  async login(username: string, password: string) {
    return await this.handleLoginReq(
      this.restService.post.bind(this.restService, "user.login", RestBody.fromPlain({ payload: UserLoginRequest.fromPlain({ username, password }) })) as {
        (): Promise<RestBody<UserLoginResponse>>;
      },
    );
  }

  /** Like login but performs the login with a JWT */
  async loginWithJWT(jwt: string) {
    return await this.handleLoginReq(
      this.restService.post.bind(this.restService, "user.loginJWT", RestBody.fromPlain({ payload: UserLoginRequest.fromPlain({ jwt }) })) as {
        (): Promise<RestBody<UserLoginResponse>>;
      },
    );
  }

  get cachedJWT() {
    return localStorage.getItem(UserService.CACHED_JWT_KEY);
  }

  set cachedJWT(jwt: string | null) {
    if (jwt == null) localStorage.removeItem(UserService.CACHED_JWT_KEY);
    else localStorage.setItem(UserService.CACHED_JWT_KEY, jwt);
  }
}
