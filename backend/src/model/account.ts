import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/model/database.base";
import { Institution } from "@backend/model/institution";
import { Account as CommonAccount } from "@common";
import { Mixin } from "ts-mixer";
import { ManyToOne } from "typeorm";

@DatabaseDecorators.entity()
export class Account extends Mixin(DatabaseBase, CommonAccount) {
  @DatabaseDecorators.column({ nullable: false, unique: true })
  declare name: string;

  @DatabaseDecorators.column({ nullable: false })
  declare provider: "simple-fin";

  @ManyToOne(() => Institution, (i) => i.id)
  declare institution: Institution;

  @DatabaseDecorators.column({ nullable: false })
  declare currency: string;

  @DatabaseDecorators.column({ nullable: false })
  declare balance: number;
  @DatabaseDecorators.column({ nullable: false })
  declare availableBalance: number;

  @DatabaseDecorators.column({ nullable: false, type: "varchar" })
  declare type: CommonAccount["type"];
}
