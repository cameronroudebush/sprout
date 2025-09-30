import { RestEndpoints } from "@backend/model/api/endpoint";
import { RestBody } from "@backend/model/api/rest.request";
import { Category } from "@backend/model/category";
import { TransactionRule } from "@backend/model/transaction.rule";
import { User } from "@backend/model/user";
import { MoreThanOrEqual } from "typeorm";
import { RestMetadata } from "../metadata";
import { SSEAPI } from "./sse";

export class TransactionRuleAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.getRules, "GET"))
  async getRules(_request: RestBody, user: User) {
    return await TransactionRule.find({ where: { user: { id: user.id } }, order: { order: "ASC" } });
  }

  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.addRule, "POST"))
  async insertRule(request: RestBody<TransactionRule>, user: User) {
    const rule = TransactionRule.fromPlain(request.payload);
    rule.user = user;

    // Find the last order and add this to the end
    const lastRule = await TransactionRule.findOne({ where: { user: { id: user.id } }, order: { order: "DESC" } });
    if (lastRule != null) rule.order = lastRule.order + 1;

    // Update the rule
    await rule.insert();

    // Run the match updates
    await TransactionRule.applyRulesToTransactions(user);
    SSEAPI.forceUpdate(user);

    return rule;
  }

  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.deleteRule, "POST"))
  async deleteRule(request: RestBody<TransactionRule>, user: User) {
    // Grab it from the database to make sure it exists for this user
    const ruleInDb = await TransactionRule.findOne({ where: { id: request.payload.id, user: { id: user.id } } });
    if (ruleInDb == null) throw new Error("Failed to locate matching rule in database.");

    await TransactionRule.deleteById(ruleInDb?.id);
    await TransactionRule.applyRulesToTransactions(user);
    SSEAPI.forceUpdate(user);
    return ruleInDb;
  }

  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.editRule, "POST"))
  async editRule(request: RestBody<TransactionRule>, user: User) {
    const matchingRule = await TransactionRule.findOne({ where: { id: request.payload.id, user: { id: user.id } } });
    if (matchingRule == null) throw new Error("Failed to find matching rule to update.");
    const newRule = TransactionRule.fromPlain({ ...request.payload, id: matchingRule.id });
    newRule.user = user;
    // Validate category
    if (newRule.category != null) {
      const matchingCat = await Category.findOne({ where: { id: newRule.category?.id, user: { id: user.id } } });
      if (matchingCat == null) throw new Error("Failed to locate matching category for transactional rule.");
      else {
        newRule.category = matchingCat;
      }
    }
    // Validate type
    if (newRule.type !== "amount" && newRule.type !== "description") throw new Error("Given type is not valid.");

    const updatedRule = await newRule.update();

    // Perform validation on editing the order. If the order has changed, we need to re-organize the other rules.
    if (newRule.order != null && newRule.order !== matchingRule.order) await TransactionRuleAPI.reorderRules(user, matchingRule.id, newRule.order);

    await TransactionRule.applyRulesToTransactions(user);
    SSEAPI.forceUpdate(user);

    return updatedRule;
  }

  /** Reorders the transaction rules for a given user.
   * @param user The user whose rules need reordering.
   * @param ruleIdToMove The ID of the rule that was moved.
   * @param newOrder The new order for the rule.
   * @returns The updated list of rules.
   */
  static async reorderRules(user: User, _ruleIdToMove: string, newOrder: number) {
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
