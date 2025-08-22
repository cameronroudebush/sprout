import { Account } from "@backend/model/account";
import { Base } from "@backend/model/base";
import { ProviderConfig } from "@backend/providers/base/config";

/** API model for how to link a providers accounts */
export class LinkProvider extends Base {
  accounts: Account[];
  provider: ProviderConfig;

  constructor(accounts: Account[], provider: ProviderConfig) {
    super();
    this.accounts = accounts;
    this.provider = provider;
  }
}
