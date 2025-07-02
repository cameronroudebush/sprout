import { User } from "@common";
import { DBBase } from "./base";
import { Institution } from "./institution";

/** This class defines an account that can provide transactional data */
export class Account extends DBBase {
  name: string;

  /** Where this account came from */
  provider: "simple-fin";

  /** The institution associated to this account */
  institution: Institution;

  /** The user this account belongs to */
  user: User;

  /** The currency this account uses */
  currency: string = "USD";

  /** The current balance of the account */
  balance: number;
  /** The available balance to this account */
  availableBalance: number;

  /** The type of this account to better separate it from the others. */
  type: "depository" | "credit" | "loan" | "investment";

  constructor(
    name: string,
    provider: Account["provider"],
    user: User,
    institution: Institution,
    balance: number,
    availableBalance: number,
    type: Account["type"],
  ) {
    super();
    this.name = name;
    this.provider = provider;
    this.user = user;
    this.institution = institution;
    this.balance = balance;
    this.availableBalance = availableBalance;
    this.type = type;
  }
}
