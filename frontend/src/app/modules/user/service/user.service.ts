import { Injectable } from "@angular/core";
import { RestBody, UserLoginRequest, UserLoginResponse } from "@common";
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
    const loginResult = await this.restService.post<UserLoginResponse>(
      "user.login",
      RestBody.fromPlain({ payload: UserLoginRequest.fromPlain({ username, password }) }),
    );
    this.store.dispatch(UserActions.addUser({ user: loginResult.payload.user }));
    this.store.dispatch(UserActions.setCurrentUser({ user: loginResult.payload.user }));
    console.log(loginResult);
  }
}
