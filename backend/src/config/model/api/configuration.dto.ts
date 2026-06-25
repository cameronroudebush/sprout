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

  /** The brandfetch client ID used for displaying logos. */
  brandFetchClientId?: string;

  /** The tile server to use for frontend mapping display. */
  tileServer?: string;

  constructor(chatKeyProvidedInBackend: boolean, emailEnabled: boolean, brandFetchClientId?: string, tileServer?: string) {
    super();
    this.chatKeyProvidedInBackend = chatKeyProvidedInBackend;
    this.emailEnabled = emailEnabled;
    this.brandFetchClientId = brandFetchClientId;
    this.tileServer = tileServer;
  }
}
