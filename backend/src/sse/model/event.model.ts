import { Base } from "@backend/core/model/base";
import { User } from "@backend/user/model/user.model";

/** This interface shows what an SSE event will contain when informing clients from the backend. */
export interface SSEEvent {
  user: User;
  data: {
    event: "sync" | "force-update";
    payload?: Base;
  };
}
