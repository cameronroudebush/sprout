import { DBBase } from "./base";

/** This institution helps keep track of what an account was created from */
export class Institution extends DBBase {
  /** The URL for where this institution is */
  url: string;
  name: string;
  /** If this institution has connection errors and needs fixed */
  hasError = false;

  constructor(url: string, name: string) {
    super();
    this.url = url;
    this.name = name;
  }
}
