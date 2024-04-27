import { ConfigurationMetadata } from "@backend/config/configuration.metadata";

/** Options that should be provided to the core of the web server */
export class ServerConfig {
  @ConfigurationMetadata.assign({ comment: "The port to accept backend requests on." })
  port: number = 8001;

  @ConfigurationMetadata.assign({ comment: "The base path we expect API requests to come in on." })
  apiBasePath: string = "";

  @ConfigurationMetadata.assign({ comment: "How long JWT's should stay valid for users" })
  jwtExpirationTime = "30m";
}
