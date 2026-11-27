import { Account } from "@backend/account/model/account.model";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRule } from "@backend/transaction/model/transaction.rule.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { FindOptionsWhere, IsNull, MoreThanOrEqual } from "typeorm";

/** This class provides functions to help with {@link TransactionRule}'s */
@Injectable()
export class TransactionRuleService {
  /**
   * Applies transaction rules to a user's transactions.
   *
   * This function iterates through all of a user's transaction rules, ordered by priority (ascending).
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
    // Full user-wide runs can recalculate counts. Partial sync/account runs must retain prior counts.
    const recalculateMatches = account == null && !onlyApplyToEmpty;
    const rules = await TransactionRule.find({
      where: { user: { id: user.id } },
      order: { order: "ASC" },
    });
    const accountWhere: FindOptionsWhere<Account> = { user: { id: user.id } };
    if (account) accountWhere.id = account.id;
    const where: FindOptionsWhere<Transaction> = {
      account: accountWhere,
    };
    if (onlyApplyToEmpty) {
      where.category = IsNull();
    }
    const transactions = await Transaction.find({
      where,
    });
    const matchedTransactionIds = new Set<string>();

    for (const rule of rules) {
      let currentRuleMatches = recalculateMatches ? 0 : rule.matches;
      if (!rule.enabled) {
        if (recalculateMatches && rule.matches !== 0) {
          rule.matches = 0;
          await rule.update();
        }
        continue; // Skip disabled rules.
      }

      for (const transaction of transactions) {
        if (matchedTransactionIds.has(transaction.id)) continue;
        if (rule.account != null && transaction.account.id !== rule.account.id) continue;

        let isMatch = false;

        if (rule.type === "description") {
          if (rule.strict) {
            isMatch = transaction.description === rule.value;
          } else {
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
          isMatch = transaction.amount === amountValue;
        }
        if (isMatch && (!transaction.manuallyEdited || (transaction.manuallyEdited && force))) {
          transaction.category = rule.category;
          transaction.manuallyEdited = false; // Reset this in the case it's set
          await transaction.update();
          currentRuleMatches++;
          matchedTransactionIds.add(transaction.id);
        }
      }
      rule.matches = currentRuleMatches;
      await rule.update();
    }
    if (resetCategories)
      for (const transaction of transactions)
        if (!matchedTransactionIds.has(transaction.id) && transaction.category !== null) {
          transaction.category = undefined;
          await transaction.update();
        }
  }

  /** Makes room at the requested priority by moving existing rules down. */
  async makeRoomForRule(user: User, order: number) {
    const rulesToMove = await TransactionRule.find({
      where: { order: MoreThanOrEqual(order), user: { id: user.id } },
      order: { order: "DESC" },
    });

    for (const rule of rulesToMove) {
      rule.order += 1;
      await rule.update();
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
    const targetPosition = newOrder;
    const matchingPriority = rules.findIndex((x) => x.order === targetPosition);
    if (matchingPriority != -1) {
      const transactionsToSlide = await TransactionRule.find({
        where: { order: MoreThanOrEqual(targetPosition!), user: { id: user.id } },
        order: { order: "ASC" },
      });
      await Promise.all(
        transactionsToSlide.map(async (x, i) => {
          const expectedIndex = x.order + 1;
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
