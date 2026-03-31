import { Base } from "@backend/core/model/base";
import { ProviderConfig } from "@backend/providers/base/model/provider.config.model";

/** This class helps correlate configuration content from the backend to the frontend */
export class APIConfig extends Base {
  /** List of providers that this application has configured and is supported */
  providers!: ProviderConfig[];

  /** Determines if the chat key is already provided and users shouldn't be able to set theirs then. */
  chatKeyProvidedInBackend: boolean;

  constructor(providers: ProviderConfig[], chatKeyProvidedInBackend: boolean) {
    super();
    this.providers = providers;
    this.chatKeyProvidedInBackend = chatKeyProvidedInBackend;
  }
}
