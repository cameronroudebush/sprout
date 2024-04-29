import { Injectable } from "@angular/core";
import { Configuration, User } from "@common";
import { RestService } from "@frontend/modules/communication/service/rest.service";
import { ServiceBase } from "@frontend/modules/shared/service/base";

@Injectable({
  providedIn: "root",
})
export class ConfigService extends ServiceBase {
  /** Currently loaded application configuration given from the backend */
  config: Configuration | undefined;
  constructor(private restService: RestService) {
    super();
  }

  override async onUserAuthenticated(_user: User) {
    // This won't change
    if (this.config == null) await this.getBackendConfig();
  }

  /** Gets backend configuration information from the backend */
  async getBackendConfig() {
    const result = await this.restService.get<Configuration>("conf.get");
    this.config = result.payload;
    console.log(this.config);
  }
}
