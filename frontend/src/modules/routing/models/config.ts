import { DashboardComponent } from "@frontend/modules/core/component/dashboard/dashboard.component";
import { HomeSetupComponent } from "@frontend/modules/setup/component/home/home.component";
import { LoginComponent } from "@frontend/modules/user/component/login/login.component";
import { AuthGuard } from "@frontend/modules/user/guard/auth.guard";
import { RouteMetadata } from "./route.metadata";
import { RouteURLs } from "./url";

/** Routes defined by the current application */
export const APP_ROUTES: RouteMetadata[] = [
  {
    path: RouteURLs.dashboard,
    component: DashboardComponent,
    canActivate: [AuthGuard],
    tabOptions: {
      label: "Dashboard",
      icon: "home",
    },
  },
  {
    path: RouteURLs.accounts,
    component: DashboardComponent, // TODO
    canActivate: [AuthGuard],
    tabOptions: {
      label: "Accounts",
      icon: "list_alt",
    },
  },
  //// ------------ Setup Module ------------
  {
    path: RouteURLs.setup,
    component: HomeSetupComponent,
    shouldRenderNav: false,
  },
  //// ------------ Base Capability ------------
  {
    path: RouteURLs.login,
    component: LoginComponent,
    shouldRenderNav: false,
  },
  // Always default to login if no users available
  { path: "**", redirectTo: RouteURLs.login },
];
