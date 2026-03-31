import { Base } from "@backend/core/model/base";
import { ProviderType } from "@backend/providers/base/provider.type";
import { ApiProperty } from "@nestjs/swagger";

/** This class represents a finance provider and some metadata on their connection */
export class ProviderConfig extends Base {
  @ApiProperty({
    enum: ProviderType,
    enumName: "ProviderTypeEnum",
  })
  dbType: ProviderType;
  /** The name of this provider */
  name: string;
  /** An endpoint of where to get this logo */
  logoUrl: string;
  /** The URL to be able to fix accounts */
  accountFixUrl?: string;

  constructor(name: string, dbType: ProviderType, logoUrl: string, accountFixUrl?: string) {
    super();
    this.name = name;
    this.dbType = dbType;
    this.logoUrl = logoUrl;
    this.accountFixUrl = accountFixUrl;
  }
}
