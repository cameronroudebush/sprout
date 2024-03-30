import { AccountsDashboardComponent } from "@frontend/modules/accounts/dashboard/dashboard.component";
import { AuthGuard } from "@frontend/modules/user/guard/auth.guard";
import { LoginComponent } from "@frontend/modules/user/login/login.component";
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
      icon: "grid",
    },
  },
  {
    path: RouteURLs.login,
    component: LoginComponent,
  },
  // Always default to login if no users available
  // { path: "", pathMatch: "full", redirectTo: RouteURLs.login },
  { path: "**", redirectTo: RouteURLs.login },
];
