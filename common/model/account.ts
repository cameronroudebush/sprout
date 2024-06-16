import { DBBase } from "./base";

/** This class defines an account that can provide transactional data */
export class Account extends DBBase {
  name: string;

  constructor(id: number, name: string) {
    super(id);
    this.name = name;
  }
}
