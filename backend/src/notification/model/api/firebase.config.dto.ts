import { Configuration } from "@backend/config/core";
import { InternalServerErrorException, Logger } from "@nestjs/common";

/** Model that defines how firebase is configured for this app */
export class FirebaseConfigDTO {
  private static readonly logger = new Logger();

  apiKey: string;
  appId: string;
  projectNumber: string;
  projectId: string;

  constructor(apiKey: string, appId: string, projectNumber: string, projectId: string) {
    this.apiKey = apiKey;
    this.appId = appId;
    this.projectNumber = projectNumber;
    this.projectId = projectId;
  }

  /** Creates this DTO from the configuration of the backend */
  static fromConfig() {
    const config = Configuration.server.notification.firebase;
    if (!config.enabled) return undefined;
    try {
      Configuration.server.notification.firebase.validate();
    } catch (e) {
      this.logger.error("Firebase Config Validation Failed", e);
      throw new InternalServerErrorException("Invalid Firebase Configuration on Server");
    }
    return new FirebaseConfigDTO(config.apiKey, config.appId, config.projectNumber.toString(), config.projectId);
  }
}
