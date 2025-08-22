import { Sync } from "@backend/model/schedule";
import { ProviderConfig } from "@backend/providers/base/config";
import { Base } from "../base";

/** A type that includes both unsecure and standard configuration for those who request it via the API */
export type CombinedExternalConfig = UnsecureAppConfiguration & Configuration;

/** This class provides additional information to those who request but it is **note secured behind authentication requirements** */
export class UnsecureAppConfiguration extends Base {
  /** If this is the first time someone has connected to this interface */
  firstTimeSetupPosition: "welcome" | "complete" = "complete";
  /** Version of the backend */
  version!: string;
}

/** This class helps correlate configuration content from the backend to the frontend */
export class Configuration extends Base {
  /** The status of the last sync we ran */
  lastSchedulerRun?: Sync;

  /** List of providers that this application has configured and is supported */
  providers: ProviderConfig[];

  constructor(lastSchedulerRun: Sync | undefined, providers: ProviderConfig[]) {
    super();
    this.lastSchedulerRun = lastSchedulerRun;
    this.providers = providers;
  }
}
