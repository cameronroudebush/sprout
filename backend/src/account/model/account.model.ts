import { AccountHistory } from "@backend/account/model/account.history.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType } from "@backend/account/model/account.type";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { Institution } from "@backend/institution/model/institution.model";
import { User } from "@backend/user/model/user.model";
import { ApiHideProperty, ApiProperty } from "@nestjs/swagger";
import { Exclude } from "class-transformer";
import { IsEnum } from "class-validator";
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
  @ManyToOne(() => User, (u) => u.id, { onDelete: "CASCADE" })
  @ApiHideProperty()
  @Exclude()
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
  @IsEnum(AccountType)
  type: AccountType;

  /** The subtype of this account. For example, a depository could be a checking account, savings account, or HYSA. */
  @DatabaseDecorators.column({ nullable: true, type: "varchar" })
  @ApiProperty({ enum: AccountSubType, enumName: "AccountSubTypeEnum", required: false })
  @IsEnum(AccountSubType)
  subType?: AccountSubType;

  /** An interest rate if this is a loan type account. */
  @DatabaseDecorators.jsonColumn({ nullable: true, type: "float" })
  @ApiProperty({ required: false, nullable: true, type: Number })
  interestRate?: number;

  /** Any extra data that we want to store as JSON */
  @DatabaseDecorators.jsonColumn({ nullable: true })
  extra?: object;

  /** Given a user, returns all accounts in the database for that user */
  static getForUser(user: User) {
    return Account.find({ where: { user: { id: user.id } } });
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
    subType?: AccountSubType,
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
    this.subType = subType;
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
    return this.type === AccountType.credit || this.type === AccountType.loan;
  }

  /** Validates that the given sub-type exists in an enum. Throws an error if it doesn't. */
  static validateSubType(subType: string) {
    const allSubTypes = Object.values(AccountSubType);
    if (!allSubTypes.includes(subType as AccountSubType)) throw new Error(`Invalid subType provided: ${subType}`);
  }
}
