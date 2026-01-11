import { Account } from "@backend/account/model/account.model";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRule } from "@backend/transaction/model/transaction.rule.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { IsNull, MoreThanOrEqual } from "typeorm";

/** This class provides functions to help with {@link TransactionRule}'s */
@Injectable()
export class TransactionRuleService {
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
   * @param force If true, will overwrite manually edited transactions. By default, this is false.
   * @param resetCategories If true, transactions that match no rules will have their categories set to null.
   */
  async applyRulesToTransactions(user: User, account?: Account, onlyApplyToEmpty = false, force = false, resetCategories = false) {
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

        // Handle requirements where certain rules only apply to certain accounts
        if (rule.account != null && transaction.account.id !== rule.account.id) continue;

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

        // The transaction matches the rule. Update its info only if we're allowed based on manually edited status.
        if (isMatch && (!transaction.manuallyEdited || (transaction.manuallyEdited && force))) {
          transaction.category = rule.category;
          transaction.manuallyEdited = false; // Reset this in the case it's set
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

    // If force is enabled, find transactions that were not "claimed" by any rule
    // and ensure their category is set to null.
    if (resetCategories)
      for (const transaction of transactions)
        if (!matchedTransactionIds.has(transaction.id) && transaction.category !== null) {
          transaction.category = undefined;
          await transaction.update();
        }
  }

  /** Reorders the transaction rules for a given user.
   * @param user The user whose rules need reordering.
   * @param ruleIdToMove The ID of the rule that was moved.
   * @param newOrder The new order for the rule.
   * @returns The updated list of rules.
   */
  async reorderRules(user: User, _ruleIdToMove: string, newOrder: number) {
    const rules = await TransactionRule.find({ where: { user: { id: user.id } }, order: { order: "ASC" } });

    // The 'newOrder' from the client is the desired 1-based position.
    const targetPosition = newOrder;

    // Find if there is a rule in that slot
    const matchingPriority = rules.findIndex((x) => x.order === targetPosition);
    if (matchingPriority != -1) {
      // Slide all down past that element
      const transactionsToSlide = await TransactionRule.find({
        where: { order: MoreThanOrEqual(targetPosition!), user: { id: user.id } },
        order: { order: "ASC" },
      });
      await Promise.all(
        transactionsToSlide.map(async (x, i) => {
          const expectedIndex = x.order + 1;
          // Handle a case where we don't need to push elements down if there is a gap in priority order
          if (expectedIndex === targetPosition + (i + 1)) {
            x.order = x.order + 1;
            await x.update();
          }
        }),
      );
    }

    return await TransactionRule.find({ where: { user: { id: user.id } }, order: { order: "ASC" } });
  }
}
