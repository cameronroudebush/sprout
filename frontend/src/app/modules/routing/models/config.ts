import { AccountsDashboardComponent } from "@frontend/modules/finance/component/dashboard/dashboard.component";
import { LoginComponent } from "@frontend/modules/user/component/login/login.component";
import { AuthGuard } from "@frontend/modules/user/guard/auth.guard";
import { RouteMetadata } from "./route.metadata";
import { RouteURLs } from "./url";

/** Routes defined by the current application */
export const APP_ROUTES: RouteMetadata[] = [
  {
    path: RouteURLs.dashboard,
    component: AccountsDashboardComponent,
    canActivate: [AuthGuard],
    tabOptions: {
      label: "Dashboard",
      icon: "dashboard",
    },
  },
  {
    path: RouteURLs.login,
    component: LoginComponent,
  },
  // Always default to login if no users available
  { path: "**", redirectTo: RouteURLs.login },
];
