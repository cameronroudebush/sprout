import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { Institution } from "@backend/institution/model/institution.model";
import { JoinColumn, OneToOne } from "typeorm";

/** Database model tracking SnapTrade brokerage authorization connections per institution. */
@DatabaseDecorators.entity()
export class SnapTradeInstitutionAsset extends DatabaseBase {
  @OneToOne(() => Institution, { onDelete: "CASCADE", eager: true })
  @JoinColumn()
  institution: Institution;

  @DatabaseDecorators.column({ type: "varchar" })
  authorizationId: string;

  constructor(institution: Institution, authorizationId: string) {
    super();
    this.institution = institution;
    this.authorizationId = authorizationId;
  }
}
