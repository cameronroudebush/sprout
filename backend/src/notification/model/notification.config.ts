import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** Notification configuration specific to firebase */
export class FirebaseConfig {
  @ConfigurationMetadata.assign({ comment: "If enabled, will send notifications to mobile apps via firebase.", restrictedValues: [true, false] })
  enabled = false;

  @ConfigurationMetadata.assign({})
  apiKey = "";
  @ConfigurationMetadata.assign({})
  appId = "";
  @ConfigurationMetadata.assign({})
  projectNumber!: number;
  @ConfigurationMetadata.assign({})
  projectId = "";
  @ConfigurationMetadata.assign({})
  clientEmail = "";
  @ConfigurationMetadata.assign({ comment: "Generated from a service account. Paste the entire string." })
  privateKey = "";

  /** Validates that the firebase config is able to be used. If not, throws an error. Doesn't validate if firebase is disabled. */
  validate() {
    if (!this.enabled) return;
    if (!this.apiKey) throw new Error("Firebase config: API key must be defined for usage.");
    if (!this.appId) throw new Error("Firebase config: App ID must be defined for usage.");
    if (!this.projectNumber) throw new Error("Firebase config: Message Sender ID must be defined for usage.");
    if (!this.projectId) throw new Error("Firebase config: Project ID must be defined for usage.");
    if (!this.clientEmail) throw new Error("Firebase config: Client email must be defined for usage.");
    if (!this.privateKey) throw new Error("Firebase config: Private Key must be defined for usage.");
  }
}

/** A class defining notification configuration */
export class NotificationConfig {
  @ConfigurationMetadata.assign({ comment: "The maximum number of notifications we store per user." })
  maxNotificationsPerUser = 10;

  @ConfigurationMetadata.assign({ comment: "Defines the configuration for firebase that allows us to send push notifications to apps." })
  firebase = new FirebaseConfig();
}
