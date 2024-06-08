import { Injectable } from "@angular/core";
import { ConfigService } from "@frontend/modules/core/service/config.service";
import { RouteURLs } from "@frontend/modules/routing/models/url";
import { RouterService } from "@frontend/modules/routing/service/router.service";
import { ServiceBase } from "@frontend/modules/shared/service/base";

@Injectable({
  providedIn: "root",
})
export class SetupService extends ServiceBase {
  constructor(
    private configService: ConfigService,
    private routerService: RouterService,
  ) {
    super();
  }

  override async initialize() {
    if (this.configService.config && this.configService.config.firstTimeSetupPosition !== "complete") this.handleFirstTimeSetup();
  }

  /** Begins the process of checking first time setup if available */
  handleFirstTimeSetup() {
    this.routerService.redirectTo(RouteURLs.setup);
  }
}
