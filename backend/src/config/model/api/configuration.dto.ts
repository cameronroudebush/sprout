import { Base } from "@backend/core/model/base";

/**
 * This class helps correlate configuration content from the backend to the frontend.
 *
 * This config is **secure** and can only be read by authenticated users.
 */
export class APIConfig extends Base {
  /** Determines if the chat key is already provided and users shouldn't be able to set theirs then. */
  chatKeyProvidedInBackend: boolean;

  /** Tracks if email is enabled and functional */
  emailEnabled: boolean;

  /** The brand fetch client ID used for displaying logos. */
  brandFetchClientId?: string;

  constructor(chatKeyProvidedInBackend: boolean, emailEnabled: boolean, brandFetchClientId?: string) {
    super();
    this.chatKeyProvidedInBackend = chatKeyProvidedInBackend;
    this.emailEnabled = emailEnabled;
    this.brandFetchClientId = brandFetchClientId;
  }
}
