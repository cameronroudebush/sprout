import { Injectable } from "@angular/core";
import { CombinedExternalConfig, UnsecureAppConfiguration, User } from "@common";
import { RestService } from "@frontend/modules/communication/service/rest.service";
import { ServiceBase } from "@frontend/modules/shared/service/base";
import { merge } from "lodash";

@Injectable({
  providedIn: "root",
})
export class ConfigService extends ServiceBase {
  /** Currently loaded application configuration given from the backend */
  config: CombinedExternalConfig | undefined;
  constructor(private restService: RestService) {
    super();
  }

  override async initialize() {
    await this.getUnsecuredConfig();
  }

  override async onUserAuthenticated(_user: User) {
    await this.getSecuredConfig();
  }

  /** Retrieves unsecured backend config information */
  async getUnsecuredConfig() {
    const result = await this.restService.get<UnsecureAppConfiguration>("conf.getUnsecure");
    this.config = merge(this.config, result.payload);
  }

  /** Retrieves additional configuration information that is secured by user authentication */
  async getSecuredConfig() {
    const result = await this.restService.get<UnsecureAppConfiguration>("conf.getUnsecure");
    this.config = merge(this.config, result.payload);
  }
}
