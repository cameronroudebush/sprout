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
    const metadata = UserConfig.getRepository().metadata;

    for (const column of metadata.columns) {
      if (column.transformer instanceof EncryptionTransformer) {
        const field = column.propertyName as keyof UserConfig;

        // If the incoming value is the masked placeholder, revert to the DB value
        if (incoming[field] === EncryptionTransformer.HIDDEN_VALUE) {
          (incoming as any)[field] = existing[field];
        } else if (field === "simpleFinToken" && incoming[field]) {
          // Convert simpleFin token as needed
          incoming[field] = await this.providerService.providers.simpleFin.convertSetupToken(incoming[field]);
        }
      }
    }
  }
}
