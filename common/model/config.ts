import { Base } from "./base";

/** This class helps correlate configuration content from the backend to the frontend */
export class Configuration extends Base {
  /** If this is the first time someone has connected to this interface */
  isFirstTimeSetup: boolean = false;
  /** Version of the backend */
  version!: string;
}
