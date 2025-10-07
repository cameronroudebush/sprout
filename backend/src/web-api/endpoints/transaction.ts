import { Account } from "@backend/model/account";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { RestBody } from "@backend/model/api/rest.request";
import { TotalTransactions, TransactionRequest } from "@backend/model/api/transaction";
import { TransactionStats, TransactionStatsRequest } from "@backend/model/api/transaction.stats";
import { Category } from "@backend/model/category";
import { Transaction } from "@backend/model/transaction";
import { User } from "@backend/model/user";
import { endOfDay, startOfDay, subDays } from "date-fns";
import { Between, FindOptionsWhere, In, IsNull, LessThan, Like, MoreThan } from "typeorm";
import { RestMetadata } from "../metadata";

export class TransactionAPI {
  /**
   * Get's transactions based on the request information in the payload. For what you can request, you should see
   *  {@link TransactionRequest}
   */
  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.get, "POST"))
  async get(request: RestBody, user: User) {
    const parsedRequest = TransactionRequest.fromPlain(request.payload);

    // Define category clause of this search
    let categoryQuery;
    if (parsedRequest.category == null) {
      categoryQuery = undefined; // No category filter
    } else if (parsedRequest.category === "Unknown") {
      categoryQuery = IsNull(); // Filter for un-categorized
    } else {
      // Handle nested categories
      const allIds = [parsedRequest.category.id];
      const queue = [parsedRequest.category.id];

      while (queue.length > 0) {
        const currentId = queue.shift()!;
        const children = await Category.find({
          where: { parentCategory: { id: currentId } },
          select: ["id"], // Only fetch the IDs for efficiency
        });

        for (const child of children) {
          allIds.push(child.id);
          queue.push(child.id);
        }
      }

      categoryQuery = { id: In(allIds) };
    }

    return await Transaction.find({
      skip: parsedRequest.startIndex,
      take: parsedRequest.endIndex,
      where: {
        account: { id: parsedRequest.accountId, user: { username: user.username } },
        category: categoryQuery,
        description: parsedRequest.description ? Like(`%${parsedRequest.description}%`) : undefined,
        posted: parsedRequest.date != null ? Between(startOfDay(parsedRequest.date), endOfDay(parsedRequest.date)) : undefined,
      },
      order: { posted: "DESC", pending: "DESC", description: "ASC" },
      relations: ["category", "category.parentCategory"],
    });
  }

  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.count, "GET"))
  async getTotalTransactions(_request: RestBody, user: User) {
    const map: TotalTransactions["accounts"] = {};
    const accounts = await Account.getForUser(user);
    for (const account of accounts) {
      const transactionCount = await Transaction.count({ where: { account: { id: account.id, user: { id: user.id } } } });
      map[account.id] = transactionCount;
    }
    const total = await Transaction.count({ where: { account: { user: { id: user.id } } } });
    return new TotalTransactions(map, total);
  }

  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.stats, "GET"))
  async getStats(request: RestBody, user: User) {
    const parsedRequest = TransactionStatsRequest.fromPlain(request.payload);
    const startDate = subDays(new Date(), parsedRequest.days);
    const where = { account: { user: { id: user.id } }, posted: MoreThan(startDate) } as FindOptionsWhere<Transaction>;
    const totalSpendResult = await Transaction.sum("amount", { ...where, ...{ amount: LessThan(0) } });
    const totalIncome = await Transaction.sum("amount", { ...where, ...{ amount: MoreThan(0) } });
    const transactionCount = await Transaction.count({ where: where });
    const largestExpenseResult = await Transaction.min("amount", where);

    const totalSpend = totalSpendResult || 0;
    const averageTransactionCost = transactionCount > 0 ? totalSpend / transactionCount : 0;
    const largestExpense = largestExpenseResult || 0;

    return TransactionStats.fromPlain({
      totalSpend: totalSpend ?? 0,
      totalIncome: totalIncome ?? 0,
      averageTransactionCost: averageTransactionCost,
      largestExpense: largestExpense,
    });
  }

  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.subscriptions, "GET"))
  async getSubscriptions(_request: RestBody, user: User) {
    return await Transaction.findSubscriptions(user);
  }

  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.edit, "POST"))
  async edit(request: RestBody<Transaction>, user: User) {
    const matchingTransaction = await Transaction.findOne({ where: { id: request.payload.id, account: { user: { id: user.id } } } });
    if (matchingTransaction == null) throw new Error("Failed to locate a matching transaction to assign update.");
    if (matchingTransaction.pending) throw new Error("Pending transactions cannot be edited.");
    // Currently, we only allow category updating
    const matchingCategory = await Category.findOne({ where: { id: request.payload.category?.id, user: { id: user.id } } });
    if (matchingCategory == null) throw new Error("Failed to locate a matching category to assign the transaction to.");
    matchingTransaction.category = matchingCategory;

    const updatedTransaction = await matchingTransaction.update();
    return updatedTransaction;
  }
}
