import { Base } from "@backend/core/model/base";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";

/** This service allows control of the Server Sent Events so we can send notifications to connected clients. */
@Injectable()
export class SSEService {
  /**
   * Given some parameters, sends a notification to the client matching those requirements.
   * @param user The user to send the SSE to. If they are connected on multiple clients, all clients will get the event.
   * @param event The event type to send.
   * @param payload Any additional payload data to send.
   */
  sendToUser(user: User, event: "sync" | "force-update", payload?: Base) {
    // TODO: Implement
    console.log(user, event, payload);
  }
}
