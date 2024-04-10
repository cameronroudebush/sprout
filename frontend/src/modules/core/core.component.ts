import { Component } from "@angular/core";
import { User } from "@common";
import { APP_ROUTES } from "@frontend/modules/routing/models/config";
import { RouteURLs } from "@frontend/modules/routing/models/url";
import { RouterService } from "@frontend/modules/routing/service/router.service";
import { SubscribingComponent } from "@frontend/modules/shared/component/subscribing-component/subscribing.component";
import { UserService } from "@frontend/modules/user/service/user.service";
import { selectCurrentUser } from "@frontend/modules/user/store/user.selector";
import { UserState } from "@frontend/modules/user/store/user.state";
import { Store } from "@ngrx/store";
import { fromEvent, map, startWith } from "rxjs";

@Component({
  selector: "app-root",
  templateUrl: "core.component.html",
  styleUrls: ["core.component.scss"],
})
export class AppComponent extends SubscribingComponent {
  /** Tracks if the navbar should be rendered horizontally (for small screens) */
  isHorizontal: boolean = false;
  currentUser: User | undefined;

  constructor(
    private store: Store<UserState>,
    private routerService: RouterService,
    public userService: UserService,
  ) {
    super();
    this.addSubscription(this.listenForHorizontalMedia().subscribe((x) => (this.isHorizontal = x)));
    this.addSubscription(this.store.select(selectCurrentUser).subscribe((user) => (this.currentUser = user)));
  }

  ngOnInit() {}

  /** Listens for the media query changing sizes to determine if we should be rendering horizontally or not */
  listenForHorizontalMedia() {
    const mediaQuery = window.matchMedia("(max-width: 768px)");
    return fromEvent<MediaQueryList>(mediaQuery, "change").pipe(
      startWith(mediaQuery),
      map((list: MediaQueryList) => list.matches),
    );
  }

  get routes() {
    return APP_ROUTES;
  }

  /** Returns if the navbar should be rendered */
  get shouldRenderNavbar() {
    return !this.routerService.isCurrentRoute(RouteURLs.login);
  }
}
