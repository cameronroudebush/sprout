import { AccountsDashboardComponent } from "../../accounts/dashboard/dashboard.component";
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
  { path: "**", redirectTo: RouteURLs.default_route },
];
