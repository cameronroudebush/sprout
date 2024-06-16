import { Injectable } from "@angular/core";
import { Account, User } from "@common";
import { AccountActions } from "@frontend/modules/accounts/store/account.actions";
import { RestService } from "@frontend/modules/communication/service/rest.service";
import { ServiceBase } from "@frontend/modules/shared/service/base";
import { UserState } from "@frontend/modules/user/store/user.state";
import { Store } from "@ngrx/store";

@Injectable({
  providedIn: "root",
})
export class AccountsService extends ServiceBase {
  constructor(
    private store: Store<UserState>,
    private restService: RestService,
  ) {
    super();
  }

  override async onUserAuthenticated(_user: User) {
    this.getAccounts();
  }

  /** Requests all accounts from the backend */
  async getAccounts() {
    const result = await this.restService.get<Account[]>("account.get");
    const accounts = Account.fromPlainArray(result.payload);
    this.store.dispatch(AccountActions.add({ data: accounts }));
  }
}
