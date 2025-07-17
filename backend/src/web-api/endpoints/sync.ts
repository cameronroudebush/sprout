import { RestEndpoints } from "@backend/model/api/endpoint";
import { Providers } from "../../providers";
import { RestMetadata } from "../metadata";

export class SyncAPI {
  /** Runs a manual schedule re-sync */
  @RestMetadata.register(new RestMetadata(RestEndpoints.sync.runManual, "GET"))
  async manualRun() {
    return await Providers.getCurrentProvider().sync.runManual();
  }
}
