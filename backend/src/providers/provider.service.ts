import { ProviderConfig } from "@backend/providers/base/config";
import { ProviderBase } from "@backend/providers/base/core";
import { SimpleFINProvider } from "@backend/providers/simple-fin/core";
import { Injectable } from "@nestjs/common";

/**
 * This service handles creation of the providers supported by sprout. This
 *  then allows us to use these across the app by accessing them in one spot
 */
@Injectable()
export class ProviderService {
  /** Providers available to the backend, defined by {@link init} */
  providers: Array<ProviderBase> = [];

  constructor() {}

  /** Initializes all providers and schedulers */
  async init() {
    /**
     * SimpleFIN
     * @link https://beta-bridge.simplefin.org/
     */
    const simpleFIN = new SimpleFINProvider(
      new ProviderConfig("SimpleFIN", "simple-fin", "https://beta-bridge.simplefin.org/static/logo.svg", "https://beta-bridge.simplefin.org/my-account"),
    );

    // Initialize the providers from above
    this.providers = [simpleFIN];
  }

  /** Returns all currently registered providers */
  getAll() {
    return this.providers;
  }
}
