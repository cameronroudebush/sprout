import { AccountHistory } from "@backend/account/model/account.history";
import { CreditAccountType, CryptoAccountType, DepositoryAccountType, InvestmentAccountType, LoanAccountType } from "@backend/account/model/account.type";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { Institution } from "@backend/institution/model/institution";
import { User } from "@backend/user/model/user";
import { ManyToOne } from "typeorm";

@DatabaseDecorators.entity()
export class Account extends DatabaseBase {
  @DatabaseDecorators.column({ nullable: false, unique: true })
  name: string;

  /** Where this account came from */
  @DatabaseDecorators.column({ nullable: false })
  provider: "simple-fin";

  /** The institution associated to this account */
  @ManyToOne(() => Institution, (i) => i.id, { eager: true, cascade: true })
  institution: Institution;

  /** The user this account belongs to */
  @ManyToOne(() => User, (u) => u.id)
  user: User;

  /** The currency this account uses */
  @DatabaseDecorators.column({ nullable: false })
  currency: string;

  /** The current balance of the account */
  @DatabaseDecorators.numericColumn({ nullable: false })
  balance: number;
  /** The available balance to this account */
  @DatabaseDecorators.numericColumn({ nullable: false })
  availableBalance: number;

  /** The type of this account to better separate it from the others. */
  @DatabaseDecorators.column({ nullable: false, type: "varchar" })
  type: "depository" | "credit" | "loan" | "investment" | "crypto";

  /** The subtype of this account. For example, a depository could be a checking account, savings account, or HYSA. */
  @DatabaseDecorators.column({ nullable: true, type: "varchar" })
  subType?: DepositoryAccountType | InvestmentAccountType | LoanAccountType | CreditAccountType | CryptoAccountType;

  /** Any extra data that we want to store as JSON */
  @DatabaseDecorators.jsonColumn({ nullable: true })
  extra?: object;

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

  /** Turns this account to act like account history for today */
  toAccountHistory(date = new Date()) {
    return AccountHistory.fromPlain({
      balance: this.balance,
      account: this,
      availableBalance: this.availableBalance,
      time: date,
    });
  }

  /** Returns if this account affects the net worth negativity due to being a loan type. */
  get isNegativeNetWorth() {
    return this.type === "credit" || this.type === "loan";
  }

  /** Validates that the given sub-type exists in an enum. Throws an error if it doesn't. */
  static validateSubType(subType: string) {
    // Validate that this sub type exists
    const allSubTypes = [
      ...Object.values(DepositoryAccountType),
      ...Object.values(InvestmentAccountType),
      ...Object.values(LoanAccountType),
      ...Object.values(CreditAccountType),
      ...Object.values(CryptoAccountType),
    ];
    if (!allSubTypes.includes(subType as any)) throw new Error(`Invalid subType provided: ${subType}`);
  }
}
