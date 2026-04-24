import { Base } from "@backend/core/model/base";

/** This class helps correlate configuration content from the backend to the frontend */
export class APIConfig extends Base {
  /** Determines if the chat key is already provided and users shouldn't be able to set theirs then. */
  chatKeyProvidedInBackend: boolean;

  /** Tracks if email is enabled and functional */
  emailEnabled: boolean;

  constructor(chatKeyProvidedInBackend: boolean, emailEnabled: boolean) {
    super();
    this.chatKeyProvidedInBackend = chatKeyProvidedInBackend;
    this.emailEnabled = emailEnabled;
  }
}
