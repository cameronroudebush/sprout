import { Component } from "@angular/core";
import { User } from "@common";
import { APP_ROUTES } from "@frontend/modules/routing/models/config";
import { RouterService } from "@frontend/modules/routing/service/router.service";
import { SubscribingComponent } from "@frontend/modules/shared/component/subscribing-component/subscribing.component";
import { UserService } from "@frontend/modules/user/service/user.service";
import { selectCurrentUser } from "@frontend/modules/user/store/user.selector";
import { UserState } from "@frontend/modules/user/store/user.state";
import { Store } from "@ngrx/store";

@Component({
  selector: "app-root",
  templateUrl: "core.component.html",
  styleUrls: ["core.component.scss"],
})
export class AppComponent extends SubscribingComponent {
  currentUser: User | undefined;

  constructor(
    private store: Store<UserState>,
    private routerService: RouterService,
    public userService: UserService,
  ) {
    super();
    this.addSubscription(this.store.select(selectCurrentUser).subscribe((user) => (this.currentUser = user)));
  }

  ngOnInit() {}

  get routes() {
    return APP_ROUTES;
  }

  /** Returns if the navbar should be rendered */
  get shouldRenderNavbar() {
    return this.routerService.getCurrentRouteConfig()?.shouldRenderNav ?? true;
  }
}
