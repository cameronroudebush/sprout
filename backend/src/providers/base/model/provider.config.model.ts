import { Base } from "@backend/core/model/base";
import { ProviderSubType, ProviderType } from "@backend/providers/base/provider.type";
import { ApiProperty } from "@nestjs/swagger";

/** This class represents a finance provider and some metadata on their connection */
export class ProviderConfig extends Base {
  @ApiProperty({
    enum: ProviderType,
    enumName: "ProviderTypeEnum",
  })
  dbType: ProviderType;
  @ApiProperty({
    enum: ProviderSubType,
    enumName: "ProviderSubTypeEnum",
  })
  subType: ProviderSubType;
  /** The name of this provider */
  name: string;
  /** Link to this provider */
  url: string;
  /** The URL to be able to fix accounts */
  accountFixUrl?: string;
  /** If this provider is available to this user. Only used during frontend communication */
  enabled: boolean = false;

  constructor(name: string, dbType: ProviderType, subType: ProviderSubType, url: string, accountFixUrl?: string) {
    super();
    this.name = name;
    this.dbType = dbType;
    this.url = url;
    this.accountFixUrl = accountFixUrl;
    this.subType = subType;
  }
}
