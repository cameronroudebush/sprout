import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/model/database.base";
import { Institution as CommonInstitution } from "@common";
import { Mixin } from "ts-mixer";

@DatabaseDecorators.entity()
export class Institution extends Mixin(DatabaseBase, CommonInstitution) {
  @DatabaseDecorators.column({ nullable: false })
  declare url: string;
  @DatabaseDecorators.column({ nullable: false })
  declare name: string;
  @DatabaseDecorators.column({ nullable: false })
  declare hasError: boolean;
}
