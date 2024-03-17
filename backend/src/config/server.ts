import { ConfigurationMetadata } from "@backend/config/configuration.metadata";

/** Options that should be provided to the core of the web server */
export class ServerConfig {
  @ConfigurationMetadata.assign({ comment: "The port to accept backend requests on." })
  port: number = 8000;

  /** The App's secret key to create things like JWT's from. This will regenerate on every reboot and can not be overridden. */
  secretKey = "DEV-KEY"; //  v4(); // TODO: Turn into a real key
}
