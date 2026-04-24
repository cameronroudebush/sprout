import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** Configuration for using email with Sprout */
export class EmailConfig {
  @ConfigurationMetadata.assign({ comment: "If emails should be supported.", restrictedValues: [true, false] })
  enabled: boolean = false;

  @ConfigurationMetadata.assign({ comment: "When to send weekly status updates. Default is 7am, every sunday." })
  sendTime: string = "0 7 * * 0";

  @ConfigurationMetadata.assign({ comment: "The email that we will send as." })
  from: string = "noreply@sprout.app.io";

  @ConfigurationMetadata.assign({ comment: "The hostname to connect to the email server at." })
  host!: string;

  @ConfigurationMetadata.assign({ comment: "Port this connection should be made on." })
  port!: number;
  @ConfigurationMetadata.assign({ comment: "If this is a TLS connection." })
  secure!: boolean;

  @ConfigurationMetadata.assign({ comment: "The username to connect to the email server with." })
  user!: string;

  @ConfigurationMetadata.assign({ comment: "The password to connect to the email server with." })
  pass!: string;

  /** Validates the config is correct. Throws an error if not */
  validate() {
    if (!this.enabled) return;
    if (!this.host) throw new Error("The host must be set to use email");
    if (!this.user) throw new Error("The username must be set to use email");
    if (!this.user) throw new Error("The password must be set to use email");
  }
}
