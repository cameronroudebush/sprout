import { ProviderService } from "@backend/providers/provider.service";
import { UserConfigController } from "@backend/user/user.config.controller";
import { UserController } from "@backend/user/user.controller";
import { UserService } from "@backend/user/user.service";
import { Module } from "@nestjs/common";

@Module({
  imports: [],
  controllers: [UserController, UserConfigController],
  providers: [UserService, ProviderService],
  exports: [UserService],
})
export class UserModule {}
