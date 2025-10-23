import { UnsecureAppConfiguration } from "@backend/config/model/api/unsecure.app.config.dto";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";

/** This service controls how the app is setup when the user sees it for the first time. */
@Injectable()
export class SetupService {
  /** Returns the information to determine if this is the first time setup of this application */
  async firstTimeSetupDetermination(): Promise<UnsecureAppConfiguration["firstTimeSetupPosition"]> {
    const adminUser = await User.find({ where: { admin: true } });
    // No admin user? We probably should ask to create that
    if (adminUser.length === 0) return "welcome"; // Return the welcome screen
    return "complete";
  }
}
