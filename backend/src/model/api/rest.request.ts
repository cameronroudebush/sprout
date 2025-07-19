import { Base } from "@backend/model/base";
import { v4 } from "uuid";

/** Types of data supported by the request messages */
export type SupportedPayloadTypes = Base | Base[] | string | number;

/** This class specifies the format of every REST request/response */
export class RestBody<PayloadType extends SupportedPayloadTypes = any> extends Base {
  payload: PayloadType;
  requestId = v4();
  timestamp = new Date();

  constructor(payload: PayloadType) {
    super();
    this.payload = payload;
  }
}

/** While very similar to a {@link RestBody}, these add an additional "queue" so we can better identify where this data is going */
export class SSEBody<PayloadType extends SupportedPayloadTypes = any> extends RestBody<PayloadType> {
  /** The queue of this SSE request so the frontend can direct it. */
  queue: string;

  constructor(queue: string, payload: PayloadType) {
    super(payload);
    this.queue = queue;
  }
}
