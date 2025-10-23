import { Account } from "@backend/account/model/account";
import { Category } from "@backend/category/model/category";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { Transaction } from "@backend/transaction/model/transaction";
import { User } from "@backend/user/model/user";
import { IsNull, ManyToOne } from "typeorm";

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
   * Applies transaction rules to a user's transactions.
   *
   * This function iterates through all of a user's transaction rules, ordered by priority (descending).
   * It applies the first matching rule to each transaction and updates the transaction's category.
   * To prevent a transaction from being matched multiple times, it keeps track of matched
   * transaction IDs and skips them in subsequent, lower-priority rule checks. This ensures
   * that the `matches` count on each rule is accurate, reflecting only the transactions
   * uniquely categorized by that rule.
   *
   * @param user The user for whom to apply the rules.
   * @param account Optional account to scope the transactions.
   * @param onlyApplyToEmpty If true, only applies rules to transactions with no category.
   */
  static async applyRulesToTransactions(user: User, account?: Account, onlyApplyToEmpty = false) {
    // Fetches rules in descending order of priority. Higher `order` values are processed first.
    const rules = await TransactionRule.find({
      where: { user: { id: user.id } },
      order: { order: "DESC" },
    });

    // Fetches all potentially relevant transactions just once.
    const transactions = await Transaction.find({
      where: {
        category: onlyApplyToEmpty ? IsNull() : undefined,
        account: { id: account?.id, user: { id: user.id } },
      },
    });

    // This Set will store the IDs of transactions that have already been matched
    // by a higher-priority rule, preventing them from being processed again.
    const matchedTransactionIds = new Set<string>();

    for (const rule of rules) {
      if (!rule.enabled) continue; // Skip disabled rules.

      let currentRuleMatches = rule.matches;

      // Iterate through all transactions for each rule.
      for (const transaction of transactions) {
        // If this transaction has already been claimed by a rule with higher priority, skip it.
        if (matchedTransactionIds.has(transaction.id)) continue;

        let isMatch = false;

        if (rule.type === "description") {
          if (rule.strict) {
            isMatch = transaction.description === rule.value;
          } else {
            // For non-strict matches, check if the description includes any of the piped values.
            const values = rule.value.split("|").map((s) => s.toLowerCase().trim());
            for (const val of values) {
              if (transaction.description.toLowerCase().includes(val)) {
                isMatch = true;
                break;
              }
            }
          }
        } else if (rule.type === "amount") {
          const amountValue = parseFloat(rule.value);
          // For amount, strict and non-strict are treated as an exact match for now.
          isMatch = transaction.amount === amountValue;
        }

        if (isMatch) {
          // The transaction matches the rule. Update its category.
          transaction.category = rule.category;
          await transaction.update();

          // Increment the match count for this specific rule.
          currentRuleMatches++;

          // Add the transaction's ID to our set to mark it as "claimed".
          matchedTransactionIds.add(transaction.id);
        }
      }

      // Update the rule's match count with the number of transactions it uniquely claimed.
      rule.matches = currentRuleMatches;
      await rule.update();
    }
  }
}
