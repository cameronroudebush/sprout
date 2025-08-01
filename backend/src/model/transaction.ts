import { DatabaseDecorators } from "@backend/database/decorators";
import { Account } from "@backend/model/account";
import { DatabaseBase } from "@backend/model/database.base";
import { User } from "@backend/model/user";
import { ManyToOne } from "typeorm";

@DatabaseDecorators.entity()
export class Transaction extends DatabaseBase {
  /** In the currency of the account */
  @DatabaseDecorators.numericColumn({ nullable: false })
  amount: number;

  @DatabaseDecorators.column({ nullable: false })
  description: string;
  @DatabaseDecorators.column()
  pending: boolean;
  @DatabaseDecorators.column({ nullable: true })
  category: string;

  /** The date this transaction posted */
  @DatabaseDecorators.column({ nullable: false })
  posted: Date;

  /** The account this transaction belongs to */
  @ManyToOne(() => Account, (a) => a.id, { eager: true, onDelete: "CASCADE" })
  account: Account;

  /** Any extra data that we want to store as JSON */
  @DatabaseDecorators.jsonColumn({ nullable: true })
  extra?: object;

  constructor(amount: number, posted: Date, description: string, category: string, pending: boolean, account: Account) {
    super();
    this.amount = amount;
    this.posted = posted;
    this.description = description;
    this.category = category;
    this.pending = pending;
    this.account = account;
  }

  /**
   * Returns a map of all categories and the times they occur for the given look-back time
   */
  static async getCategories(user: User, dateToLookBackTo: Date) {
    const repository = Transaction.getRepository();
    const uniqueCategories = await repository
      .createQueryBuilder("transaction")
      .select("transaction.category", "category")
      .addSelect("COUNT(*)", "count")
      .innerJoin(Account, "account", "transaction.accountId = account.id")
      .where("account.userId = :userId", { userId: user.id })
      .andWhere("transaction.posted >= :oneMonthAgo", { oneMonthAgo: dateToLookBackTo })
      .groupBy("transaction.category")
      .getRawMany();

    return uniqueCategories.reduce((acc: { [category: string]: number }, curr: { category: string | null; count: string }) => {
      const categoryName = curr.category ?? "Unknown"; // Check for null and set to "Unknown"
      acc[categoryName] = parseInt(curr.count);
      return acc;
    }, {});
  }
}
