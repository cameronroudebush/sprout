import { DBBase } from "./base";

/** This class defines an account that can provide transactional data */
export class Account extends DBBase {
  name: string;

  /** Where this account came from */
  source: "plaid";

  /** The ID from the API that resolved this account */
  apiId: string;

  constructor(id: string, name: string, source: Account["source"], apiId: string) {
    super(id);
    this.name = name;
    this.source = source;
    this.apiId = apiId;
  }
}
