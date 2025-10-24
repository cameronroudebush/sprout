import { Base } from "@backend/core/model/base";
import { SSEEvent } from "@backend/sse/model/event.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { Observable, Subject, filter, map } from "rxjs";

/** This service allows control of the Server Sent Events so we can send notifications to connected clients. */
@Injectable()
export class SSEService {
  /** This event source is how we tell SSE listeners of upcoming events. */
  private readonly eventSource = new Subject<SSEEvent>();

  /**
   * Given some parameters, sends a notification to the client matching those requirements.
   * @param user The user to send the SSE to. If they are connected on multiple clients, all clients will get the event.
   * @param event The event type to send.
   * @param payload Any additional payload data to send.
   */
  sendToUser(user: User, event: SSEEvent["data"]["event"], payload?: Base) {
    this.eventSource.next({ user, data: { event, payload } });
  }

  /**
   * Subscribes a user to the SSE event stream.
   * @param user The user to subscribe.
   * @returns An Observable that emits MessageEvent objects for the subscribed user.
   */
  subscribe(user: User): Observable<MessageEvent> {
    return this.eventSource.asObservable().pipe(
      filter((event) => event.user.id === user.id),
      map((event) => ({ data: JSON.stringify(event.data) }) as MessageEvent),
    );
  }
}
