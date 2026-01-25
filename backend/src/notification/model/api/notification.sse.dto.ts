import { Base } from "@backend/core/model/base";
import { IsBoolean } from "class-validator";

/** A class of data that is sent across the SSE */
export class NotificationSSEDTO extends Base {
  /** If we should render the latest notification or not */
  @IsBoolean()
  popupLatest: boolean;

  constructor(popupLatest: boolean) {
    super();
    this.popupLatest = popupLatest;
  }
}
