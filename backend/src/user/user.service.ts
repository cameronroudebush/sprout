import { Configuration } from "@backend/config/core";
import { EncryptionTransformer } from "@backend/core/decorator/encryption.decorator";
import { Institution } from "@backend/institution/model/institution.model";
import { ProviderBase } from "@backend/providers/base/core";
import { PROVIDER_LIST_TOKEN } from "@backend/providers/model/constants";
import { SimpleFINProviderService } from "@backend/providers/simple-fin/simple-fin.provider.service";
import { UserConfig } from "@backend/user/model/user.config.model";
import { User } from "@backend/user/model/user.model";
import { Inject, Injectable, InternalServerErrorException, Logger } from "@nestjs/common";

@Injectable()
export class UserService {
  private readonly logger = new Logger("service:user");

  constructor(
    @Inject(PROVIDER_LIST_TOKEN) private readonly providers: ProviderBase[],
    private readonly simpleFinProviderService: SimpleFINProviderService,
  ) {}

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
          incoming[key] = await this.simpleFinProviderService.convertSetupToken(incoming[key]);
        }
      }
    }
  }

  /**
   * Safely deletes a user by explicitly unlinking all of their remote financial
   * connections first. Aborts the deletion if a remote provider fails to unlink.
   *
   * @param forceDelete Forcibly deletes the user even if it fails to unlink some institutions. NOTE: This could incur
   *  additional costs from the finance API's.
   */
  async deleteUser(user: User, forceDelete: boolean = false) {
    this.logger.log(`Beginning account deletion process for user ${user.id}`);
    const institutions = await Institution.find({ where: { user: { id: user.id } } });

    for (const institution of institutions) {
      for (const prov of this.providers) {
        try {
          const success = await prov.unlinkInstitution(user, institution.id);
          if (!success && !forceDelete) {
            this.logger.error(`Aborting user deletion: ${prov.config.name} failed to unlink institution ${institution.id}.`);
            throw new InternalServerErrorException(
              `Failed to disconnect financial connection from ${prov.config.name}. Please try again later or contact the administrator.`,
            );
          }
        } catch (e) {
          // If a hard exception was thrown (network crash, etc)
          if (e instanceof InternalServerErrorException) throw e;
          this.logger.error(`Critical error executing remote unlink via ${prov.config.name} for institution ${institution.id}`, e);
          if (!forceDelete) throw new InternalServerErrorException(`Unexpected error disconnecting from ${prov.config.name}. Account deletion aborted.`);
        }
      }
    }

    await user.remove();
    this.logger.log(`Successfully deleted user ${user.id}`);
  }
}
