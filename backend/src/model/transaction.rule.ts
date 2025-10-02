import { DatabaseDecorators } from "@backend/database/decorators";
import { Account } from "@backend/model/account";
import { Category } from "@backend/model/category";
import { DatabaseBase } from "@backend/model/database.base";
import { Transaction } from "@backend/model/transaction";
import { User } from "@backend/model/user";
import { ManyToOne } from "typeorm";

/** This class defines a rule that allows us to organize transactions based on a rule  */
@DatabaseDecorators.entity()
export class TransactionRule extends DatabaseBase {
  @ManyToOne(() => User, (u) => u.id, { onDelete: "CASCADE" })
  user: User;

  @DatabaseDecorators.column({ nullable: false })
  type: "description" | "amount";

  /** This defines the value of the rule. Strings support | to split content */
  @DatabaseDecorators.column({ nullable: false })
  value: string;

  /** This defines the category to set the transaction to */
  @ManyToOne(() => Category, { nullable: true, eager: true, onDelete: "SET NULL" })
  category?: Category;

  /** If this match should be strict. So if it should be the exact string or the exact number. */
  @DatabaseDecorators.column({ nullable: false })
  strict: boolean;

  /** How many transactions have been updated by this transaction rule. */
  @DatabaseDecorators.column({ nullable: false })
  matches: number = 0;

  /** The order of priority of this value */
  @DatabaseDecorators.column({ nullable: false })
  order: number = 0;

  /** If this rule should be executed */
  @DatabaseDecorators.column({ nullable: false })
  enabled: boolean = true;

  constructor(user: User, type: "description" | "amount", value: string, category?: Category, strict: boolean = false) {
    super();
    this.user = user;
    this.type = type;
    this.value = value;
    this.category = category;
    this.strict = strict;
  }

  /**
   * Iterates over the transaction table and attempts to handle the transaction rules for a given user.
   *
   * @param user The user to apply the rules for.
   * @param account A specific account we only want to apply the rules for. If this is not given, rules will be run for all user accounts
   */
  static async applyRulesToTransactions(user: User, account?: Account) {
    const rules = await TransactionRule.find({ where: { user: { id: user.id } } });
    const transactions = await Transaction.find({ where: { account: { id: account?.id, user: { id: user.id } } } });

    for (const rule of rules) {
      if (!rule.enabled) continue; // Ignore disabled rules
      let matches = 0;
      for (const transaction of transactions) {
        let matched = false;
        if (rule.type === "description") {
          if (rule.strict) {
            matched = transaction.description === rule.value;
          } else {
            const values = rule.value.split("|").map((s) => s.toLowerCase().trim());
            for (const val of values) {
              if (transaction.description.toLowerCase().includes(val)) {
                matched = true;
                break;
              }
            }
          }
        } else if (rule.type === "amount") {
          const val = parseFloat(rule.value);
          if (rule.strict) {
            matched = transaction.amount === val;
          } else {
            // Even when comparing amount, if non strict, still assume exact value. We may add support in the future for ranges.
            matched = transaction.amount === val;
          }
        }

        if (matched) {
          transaction.category = rule.category;
          await transaction.update();
          matches++;
        }
      }

      rule.matches = matches;
      await rule.update();
    }
  }
}
