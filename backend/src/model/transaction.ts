import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/model/database.base";
import { User } from "@backend/model/user";
import { Transaction as CommonTransaction } from "@common";
import { Mixin } from "ts-mixer";
import { ManyToOne, Relation } from "typeorm";

@DatabaseDecorators.entity()
export class Transaction extends Mixin(DatabaseBase, CommonTransaction) {
  @ManyToOne(() => User, (user) => user.username)
  declare user: Relation<User>;

  @DatabaseDecorators.column({ nullable: false })
  declare amount: number;

  @DatabaseDecorators.column({ nullable: false })
  declare date: Date;
}
