import { ProviderModule } from "@backend/providers/provider.module";
import { UserConfigController } from "@backend/user/user.config.controller";
import { UserController } from "@backend/user/user.controller";
import { UserService } from "@backend/user/user.service";
import { Module } from "@nestjs/common";

@Module({
  imports: [ProviderModule],
  controllers: [UserController, UserConfigController],
  providers: [UserService],
  exports: [UserService],
})
export class UserModule {}
