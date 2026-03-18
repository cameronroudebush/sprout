import { Configuration } from "@backend/config/core";
import { CanActivate, Injectable, NotFoundException } from "@nestjs/common";

/** A guard that when applied to an endpoint disables it's ability from showing up if we're not in dev mode */
@Injectable()
export class DevModeGuard implements CanActivate {
  canActivate(): boolean {
    if (Configuration.isDevBuild) return true;
    throw new NotFoundException();
  }
}
