import { RestEndpoints } from "@backend/model/api/endpoint";
import { RestBody } from "@backend/model/api/rest.request";
import { User } from "@backend/model/user";
import { Providers } from "../../providers";
import { RestMetadata } from "../metadata";
import { SSEAPI } from "./sse";

export class SyncAPI {
  /** Runs a manual schedule re-sync */
  @RestMetadata.register(new RestMetadata(RestEndpoints.sync.runManual, "GET"))
  async manualRun(_: RestBody, user: User) {
    const syncRun = await Providers.getCurrentProvider().sync.runManual();
    // Inform of the completed sync
    SSEAPI.sendToSSEUser.next({ payload: syncRun, queue: "sync", user });
    return syncRun;
  }
}
