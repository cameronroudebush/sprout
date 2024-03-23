import { v4 } from "uuid";
import { Base } from "./base";

/** Types of data supported by the request messages */
export type SupportedPayloadTypes = Base | string | number;

/** This class specifies the format of every rest request */
export class RestRequest<PayloadType extends SupportedPayloadTypes> extends Base {
  queue: string;
  payload: PayloadType;
  requestId = v4();
  timestamp = new Date();

  constructor(queue: string, payload: PayloadType) {
    super();
    this.queue = queue;
    this.payload = payload;
  }
}
