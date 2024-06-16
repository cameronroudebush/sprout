import { Injectable } from "@angular/core";
import { CustomTypes } from "@common";
import { AccountsService } from "@frontend/modules/accounts/service/accounts.service";
import { RouterService } from "@frontend/modules/routing/service/router.service";
import { SetupService } from "@frontend/modules/setup/service/setup.service";
import { ServiceBase } from "@frontend/modules/shared/service/base";
import { UserService } from "@frontend/modules/user/service/user.service";
import { selectCurrentUser } from "@frontend/modules/user/store/user.selector";
import { UserState } from "@frontend/modules/user/store/user.state";
import { Store } from "@ngrx/store";
import { ConfigService } from "../../core/service/config.service";

/** This service manager provides base capabilities that can handle functionality for other registered services */
@Injectable({
  providedIn: "root",
})
export class ServiceManager {
  /** The order at which we fire functionality for services */
  serviceExecutionOrder: Array<ServiceBase> = [];

  constructor(
    private store: Store<UserState>,
    routerService: RouterService,
    userService: UserService,
    configService: ConfigService,
    setupService: SetupService,
    accountsService: AccountsService,
  ) {
    this.serviceExecutionOrder = [routerService, userService, configService, setupService, accountsService];
    // Subscribe to relevant events
    this.store.select(selectCurrentUser).subscribe((x) => {
      if (x) this.callFnc("onUserAuthenticated", x);
      else this.callFnc("onUserUnAuthenticated");
    });
  }

  /**
   * Calls the internal function given with an arguments as required in the order defined by the constructor
   */
  async callFnc<T extends Function>(fncName: CustomTypes.PropertyNames<ServiceBase, T>, ...args: Parameters<ServiceBase[typeof fncName]>) {
    for (let service of this.serviceExecutionOrder) await (service[fncName] as any)?.call(service, ...args);
  }
}
