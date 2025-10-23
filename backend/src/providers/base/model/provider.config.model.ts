import { Base } from "@backend/core/model/base";

export type PROVIDER_OPTIONS = "simple-fin";

/** This class represents a finance provider and some metadata on their connection */
export class ProviderConfig extends Base {
  dbType: PROVIDER_OPTIONS;
  /** The name of this provider */
  name: string;
  /** An endpoint of where to get this logo */
  logoUrl: string;
  /** The URL to be able to fix accounts */
  accountFixUrl?: string;

  constructor(name: string, dbType: PROVIDER_OPTIONS, logoUrl: string, accountFixUrl?: string) {
    super();
    this.name = name;
    this.dbType = dbType;
    this.logoUrl = logoUrl;
    this.accountFixUrl = accountFixUrl;
  }
}
