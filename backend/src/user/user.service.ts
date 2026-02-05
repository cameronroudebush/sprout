import { Configuration } from "@backend/config/core";
import { EncryptionTransformer } from "@backend/core/decorator/encryption.decorator";
import { ProviderService } from "@backend/providers/provider.service";
import { UserConfig } from "@backend/user/model/user.config.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";

@Injectable()
export class UserService {
  constructor(private readonly providerService: ProviderService) {}

  /** Returns if users are allowed to be created because either it's first time setup or OIDC mode and new users are allowed. */
  async allowUserCreation() {
    if (Configuration.server.auth.type === "oidc") return Configuration.server.auth.oidc.allowNewUsers;
    else return (await User.count()) === 0;
  }

  /** Syncs encrypted fields for our user config. Does this dynamically based on the value of the transformer */
  async syncEncryptedFields(incoming: UserConfig, existing: UserConfig) {
    const keys = Object.keys(existing) as (keyof UserConfig)[];

    // Loop over all keys, determine who is encrypted and what needs updated
    for (const key of keys) {
      if (EncryptionTransformer.propertyIsEncrypted(existing, key)) {
        // If the incoming value is the masked placeholder, revert to the DB value
        if (incoming[key] === EncryptionTransformer.HIDDEN_VALUE) {
          (incoming as any)[key] = existing[key];
        } else if (key === "simpleFinToken" && incoming[key]) {
          // Convert simpleFin token as needed
          incoming[key] = await this.providerService.providers.simpleFin.convertSetupToken(incoming[key]);
        }
      }
    }
  }
}
