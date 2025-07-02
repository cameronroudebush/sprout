import { Base } from "@backend/model/base";

/** Required content to be sent when we request transactional data */
export class TransactionRequest extends Base {
  startIndex: number;
  endIndex: number;

  constructor(startIndex: number, endIndex: number) {
    super();
    this.startIndex = startIndex;
    this.endIndex = endIndex;
  }
}
