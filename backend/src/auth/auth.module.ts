import { AuthController } from "@backend/auth/auth.controller";
import { AuthService } from "@backend/auth/auth.service";
import { LocalStrategy } from "@backend/auth/local.strategy";
import { OIDCStrategy } from "@backend/auth/oidc.strategy";
import { Configuration } from "@backend/config/core";
import { HttpModule } from "@nestjs/axios";
import { CacheModule } from "@nestjs/cache-manager";
import { Module, Provider } from "@nestjs/common";
import { PassportModule } from "@nestjs/passport";

const authProviders = [AuthService] as Provider[];

// Based on config, assign the strategy. We've already validated it during the auth guard setup.
if (Configuration.server.auth.type === "oidc") {
  authProviders.push(OIDCStrategy);
} else {
  authProviders.push(LocalStrategy);
}

@Module({
  imports: [PassportModule, HttpModule, CacheModule.register()],
  controllers: [AuthController],
  providers: authProviders,
  exports: [AuthService],
})
export class AuthModule {}
