import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/model/database.base";
import { Institution } from "@backend/model/institution";
import { User } from "@backend/model/user";
import { ManyToOne } from "typeorm";

@DatabaseDecorators.entity()
export class Account extends DatabaseBase {
  @DatabaseDecorators.column({ nullable: false, unique: true })
  name: string;

  /** Where this account came from */
  @DatabaseDecorators.column({ nullable: false })
  provider: "simple-fin";

  /** The institution associated to this account */
  @ManyToOne(() => Institution, (i) => i.id)
  institution: Institution;

  /** The user this account belongs to */
  @ManyToOne(() => User, (u) => u.id)
  user: User;

  /** The currency this account uses */
  @DatabaseDecorators.column({ nullable: false })
  currency: string;

  /** The current balance of the account */
  @DatabaseDecorators.column({ nullable: false })
  balance: number;
  /** The available balance to this account */
  @DatabaseDecorators.column({ nullable: false })
  availableBalance: number;

  /** The type of this account to better separate it from the others. */
  @DatabaseDecorators.column({ nullable: false, type: "varchar" })
  type: "depository" | "credit" | "loan" | "investment";

  /** Given a user, returns all accounts in the database for that user */
  static getForUser(user: User) {
    return Account.find({ where: { user } });
  }

  constructor(
    name: string,
    provider: Account["provider"],
    user: User,
    institution: Institution,
    balance: number,
    availableBalance: number,
    type: Account["type"],
    currency: string,
  ) {
    super();
    this.name = name;
    this.provider = provider;
    this.user = user;
    this.institution = institution;
    this.balance = balance;
    this.availableBalance = availableBalance;
    this.type = type;
    this.currency = currency;
  }
}
