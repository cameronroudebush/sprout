import { Configuration } from "@backend/config/core";
import { UserDevice } from "@backend/user/model/user.device.model";
import { LessThan } from "typeorm";
import { BackgroundJob } from "./base";

/** This class defines a background job that executes to check user devices and clean them up if we haven't seen them in awhile */
export class UserDeviceJob extends BackgroundJob<any> {
  constructor() {
    super("user:device", Configuration.user.deviceCheckTime);
  }

  override async start() {
    return super.start(true); // Always check immediately on startup
  }

  protected async update() {
    this.logger.log("Checking for outdated user devices...");
    const days = Configuration.user.days;
    // Calculate the cutoff date
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - days);
    // Perform the deletion
    const result = await UserDevice.delete({
      lastSeenAt: LessThan(cutoffDate),
    });

    if (result.affected && result.affected > 0) {
      this.logger.warn(`Cleaning up ${result.affected} user devices that we haven't seen in awhile.`);
    } else this.logger.log("No user devices to clean up.");
  }
}
