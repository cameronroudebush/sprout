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
  constructor(
    private store: Store<UserState>,
    private restService: RestService,
  ) {}

  /** Given some user information, performs a login request */
  async login(username: string, password: string) {
    try {
      const loginResult = await this.restService.post<UserLoginResponse>(
        "user.login",
        RestBody.fromPlain({ payload: UserLoginRequest.fromPlain({ username, password }) }),
      );
      const user = User.fromPlain(loginResult.payload.user);
      this.store.dispatch(UserActions.addUser({ user }));
      this.store.dispatch(UserActions.setCurrentUser({ user }));
      return user;
    } catch (e) {
      return { isError: true, message: (e as HttpErrorResponse).error };
    }
  }
}
