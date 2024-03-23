import { Route } from "@angular/router";
import * as ionIcons from "ionicons/icons";

/** The metadata that each route can support to improve dynamic rendering */
export interface RouteMetadata extends Route {
  /** Options so this route can be dynamically rendered on the tabs display */
  tabOptions?: {
    /** What to call this route on the tabs */
    label: string;
    /** The icon to use for this tab */
    icon: keyof typeof ionIcons;
  };
}
