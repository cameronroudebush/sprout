import { Account } from "@backend/model/account";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { RestBody } from "@backend/model/api/rest.request";
import { TotalTransactions, TransactionQueryRequest, TransactionRequest } from "@backend/model/api/transaction";
import { TransactionStats, TransactionStatsRequest } from "@backend/model/api/transaction.stats";
import { Transaction } from "@backend/model/transaction";
import { User } from "@backend/model/user";
import { subDays } from "date-fns";
import { FindOptionsWhere, LessThan, Like, MoreThan } from "typeorm";
import { RestMetadata } from "../metadata";

export class TransactionAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.get, "POST"))
  async getTransactions(request: RestBody, user: User) {
    const parsedRequest = TransactionRequest.fromPlain(request.payload);
    return await Transaction.find({
      skip: parsedRequest.startIndex,
      take: parsedRequest.endIndex,
      where: {
        account: { id: parsedRequest.accountId, user: { username: user.username } },
        category: parsedRequest.category ? { name: Like(parsedRequest.category) } : undefined,
      },
      order: { posted: "DESC" },
    });
  }

  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.getByDescription, "GET"))
  async getTransactionsByDescription(request: RestBody, user: User) {
    const parsedRequest = TransactionQueryRequest.fromPlain(request.payload);
    return await Transaction.find({
      where: { account: { id: parsedRequest.accountId, user: { username: user.username } }, description: Like(`%${parsedRequest.description!}%`) },
      order: { posted: "DESC" },
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
}
