import { ProviderBase } from "@backend/providers/base/core";
import { SimpleFINProvider } from "@backend/providers/simple-fin/core";

/**
 * This handles creation of the providers supported by sprout. This
 *  then allows us to use these across the app by accessing one namespace.
 */
export namespace Providers {
  /** Providers available to the backend, defined by {@link initializeProviders} */
  let providers: Array<ProviderBase> = [];

  /** Initializes all providers and schedulers */
  export async function initializeProviders() {
    /**
     * SimpleFIN
     * @link https://beta-bridge.simplefin.org/
     */
    const simpleFIN = new SimpleFINProvider();

    // Initialize the providers from above
    providers = [simpleFIN];
  }

  /** Returns the currently configured provider for sprout. */
  export function getCurrentProvider() {
    return providers[0]!;
  }
}
