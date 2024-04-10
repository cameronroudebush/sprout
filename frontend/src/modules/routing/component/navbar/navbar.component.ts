import { Component, OnInit } from "@angular/core";
import { APP_ROUTES } from "@frontend/modules/routing/models/config";
import { RouteURLs } from "@frontend/modules/routing/models/url";
import { RouterService } from "@frontend/modules/routing/service/router.service";
import { SubscribingComponent } from "@frontend/modules/shared/component/subscribing-component/subscribing.component";
import { UserService } from "@frontend/modules/user/service/user.service";
import { fromEvent, map, startWith } from "rxjs";

/** Navbar to render based on our application sizing */
@Component({
  selector: "shared-navbar",
  templateUrl: "./navbar.component.html",
  styleUrls: ["./navbar.component.scss"],
})
export class NavbarComponent extends SubscribingComponent implements OnInit {
  /** Tracks if the navbar should be rendered horizontally (for small screens) */
  isHorizontal: boolean = false;

  constructor(
    private routerService: RouterService,
    public userService: UserService,
  ) {
    super();
    this.addSubscription(this.listenForHorizontalMedia().subscribe((x) => (this.isHorizontal = x)));
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

  /** Returns if the navbar should be rendered */
  get shouldRenderNavbar() {
    return !this.routerService.isCurrentRoute(RouteURLs.login);
  }

  get routes() {
    return APP_ROUTES;
  }
}
