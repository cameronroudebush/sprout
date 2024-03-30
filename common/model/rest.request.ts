import { v4 } from "uuid";
import { Base } from "./base";

/** Types of data supported by the request messages */
export type SupportedPayloadTypes = Base | string | number;

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
