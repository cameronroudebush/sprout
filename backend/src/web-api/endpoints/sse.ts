import { SSEBody } from "@backend/model/api/rest.request";
import { Base } from "@backend/model/base";
import { User } from "@backend/model/user";
import { Request, Response } from "express";
import { filter, Subject } from "rxjs";

/** This class exposes an API for server sent events */
export class SSEAPI {
  /** A message bus used to send to an SSE endpoint for the given user. */
  static sendToSSEUser = new Subject<{ payload: Base; queue: string; user: User }>();

  /** This function initializes an SSE listener for a specific user. It will send messages from the bus as necessary. */
  setupSSEListener(req: Request, res: Response, user: User) {
    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.setHeader("Connection", "keep-alive");
    res.flushHeaders();

    // Listen to messages we wish to send
    const sub = SSEAPI.sendToSSEUser.pipe(filter((z) => z.user.id === user.id)).subscribe((x) => {
      const message = SSEBody.fromPlain({ queue: x.queue, payload: x.payload });
      res.write(`data: ${message.toJSONString()}\n\n`);
    });

    req.on("close", () => {
      res.end();
      sub.unsubscribe();
    });
  }
}
