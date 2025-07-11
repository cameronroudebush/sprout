import { ProviderBase } from "@backend/providers/base/core";
import { SimpleFINProvider } from "@backend/providers/simple-fin/core";

/**
 * This handles creation of the providers supported by sprout. This
 *  then allows us to use these across the app by accessing one namespace.
 */
export namespace Providers {
  /**
   * @link https://beta-bridge.simplefin.org/
   */
  const SIMPLE_FIN = new SimpleFINProvider();

  /** Returns the currently configured provider for sprout. */
  export function getCurrentProvider(): ProviderBase {
    return SIMPLE_FIN;
  }
}
