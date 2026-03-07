import { ProviderBase } from "@backend/providers/base/core";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";
import { SimpleFINProvider } from "@backend/providers/simple-fin/core";
import { ZillowProvider } from "@backend/providers/zillow/core";
import { HttpService } from "@nestjs/axios";
import { Injectable } from "@nestjs/common";

/**
 * This service handles creation of the providers supported by sprout. This
 *  then allows us to use these across the app by accessing them in one spot
 */
@Injectable()
export class ProviderService {
  /** Providers available to the backend, defined by {@link init} */
  providers: { simpleFin: SimpleFINProvider; zillow: ZillowProvider } = {} as any;

  constructor(private readonly httpService: HttpService) {}

  /** Initializes all providers and schedulers */
  async init() {
    /**
     * SimpleFIN
     * @link https://beta-bridge.simplefin.org/
     */
    this.providers.simpleFin = new SimpleFINProvider(
      new ProviderConfig("SimpleFIN", "simple-fin", "https://beta-bridge.simplefin.org/static/logo.svg", "https://beta-bridge.simplefin.org/my-account"),
      this.httpService,
    );

    /**
     * Zillow
     */
    this.providers.zillow = new ZillowProvider(new ProviderConfig("Zillow", "zillow", "https://www.zillow.com/apple-touch-icon.png"), this.httpService);
  }

  /** Returns all currently registered providers as an array */
  getAll(): Array<ProviderBase> {
    return Object.values(this.providers);
  }
}
