import { Base } from "@backend/core/model/base";
import { Sync } from "@backend/jobs/model/sync.model";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";

/** This class helps correlate configuration content from the backend to the frontend */
export class APIConfig extends Base {
  /** The status of the last sync we ran */
  lastSchedulerRun?: Sync;

  /** List of providers that this application has configured and is supported */
  providers!: ProviderConfig[];

  /** Determines if the chat key is already provided and users shouldn't be able to set theirs then. */
  chatKeyProvidedInBackend: boolean;

  constructor(lastSchedulerRun: Sync | undefined, providers: ProviderConfig[], chatKeyProvidedInBackend: boolean) {
    super();
    this.lastSchedulerRun = lastSchedulerRun;
    this.providers = providers;
    this.chatKeyProvidedInBackend = chatKeyProvidedInBackend;
  }
}
