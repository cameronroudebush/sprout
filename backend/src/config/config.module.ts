import { ConfigController } from "@backend/config/config.controller";
import { ConfigurationService } from "@backend/config/config.service";
import { SproutLogger } from "@backend/core/logger";
import { UserModule } from "@backend/user/user.module";
import { Module } from "@nestjs/common";

@Module({
  imports: [UserModule],
  controllers: [ConfigController],
  providers: [ConfigurationService, SproutLogger],
  exports: [ConfigurationService],
})
export class ConfigurationModule {}
