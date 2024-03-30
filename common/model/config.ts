import { Base } from "./base";

/** This class helps correlate configuration content from the backend to the frontend */
export class Configuration extends Base {
  /** Version of the backend */
  version!: string;
}
