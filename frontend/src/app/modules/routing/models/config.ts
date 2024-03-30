import { AccountsDashboardComponent } from "@frontend/modules/accounts/dashboard/dashboard.component";
import { LoginComponent } from "@frontend/modules/user/login/login.component";
import { RouteMetadata } from "./route.metadata";
import { RouteURLs } from "./url";

/** Routes defined by the current application */
export const APP_ROUTES: RouteMetadata[] = [
  {
    path: RouteURLs.dashboard,
    component: AccountsDashboardComponent,
    tabOptions: {
      label: "Dashboard",
      icon: "grid",
    },
  },
  {
    path: RouteURLs.login,
    component: LoginComponent,
  },
  { path: "**", redirectTo: RouteURLs.default_route },
];
