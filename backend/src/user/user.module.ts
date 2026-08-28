import { ProviderModule } from "@backend/providers/provider.module";
import { SSEModule } from "@backend/sse/sse.module";
import { UserDeviceJob } from "@backend/user/jobs/user.device";
import { UserConfigController } from "@backend/user/user.config.controller";
import { UserController } from "@backend/user/user.controller";
import { UserService } from "@backend/user/user.service";
import { Module } from "@nestjs/common";

@Module({
  imports: [ProviderModule, SSEModule],
  controllers: [UserController, UserConfigController],
  providers: [UserService, UserDeviceJob],
  exports: [UserService],
})
export class UserModule {}
