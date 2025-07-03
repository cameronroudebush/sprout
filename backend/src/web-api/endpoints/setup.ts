import { Logger } from "@backend/logger";
import { UnsecureAppConfiguration } from "@backend/model/api/config";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { RestBody } from "@backend/model/api/rest.request";
import { UserCreationRequest, UserCreationResponse } from "@backend/model/api/user";
import { User } from "@backend/model/user";
import { EndpointError } from "../error";
import { RestMetadata } from "../metadata";

/** API endpoints related to first time setup */
export class SetupAPI {
  /** Returns the information to determine if this is the first time setup of this application */
  static async firstTimeSetupDetermination(): Promise<UnsecureAppConfiguration["firstTimeSetupPosition"]> {
    const adminUser = await User.find({ where: { admin: true } });
    // No admin user? We probably should ask to create that
    if (adminUser.length === 0) return "welcome"; // Return the welcome screen
    return "complete";
  }

  /** Returns the app configuration for the frontend to be able to reference */
  @RestMetadata.register(new RestMetadata(RestEndpoints.setup.createUser, "POST", false))
  async createAdminAccount(data: RestBody<UserCreationRequest>) {
    try {
      const firstTimeSetupStatus = await SetupAPI.firstTimeSetupDetermination();
      if (firstTimeSetupStatus === "welcome") {
        const user = await User.createUser(data.payload.username, data.payload.password, true);
        Logger.info("Admin account created");
        return UserCreationResponse.fromPlain({ username: user.username });
      } else throw new EndpointError("The app is not in a setup state.");
    } catch (e) {
      Logger.error(e as Error);
      return UserCreationResponse.fromPlain({ username: data.payload.username, success: "Failed to create admin account for setup" });
    }
  }
}
