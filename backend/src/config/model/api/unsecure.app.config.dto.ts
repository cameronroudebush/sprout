import { Base } from "@backend/core/model/base";

/** This class provides additional information to those who request but it is **note secured behind authentication requirements** */
export class UnsecureAppConfiguration extends Base {
  /** If this is the first time someone has connected to this interface */
  firstTimeSetupPosition: "welcome" | "complete";
  /** Version of the backend */
  version: string;

  constructor(firstTimeSetupPosition: "welcome" | "complete" = "complete", version: string) {
    super();
    this.firstTimeSetupPosition = firstTimeSetupPosition;
    this.version = version;
  }
}
