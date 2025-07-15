import { Account } from "@backend/model/account";
import { AccountHistory } from "@backend/model/account.history";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { NetWorthOverTime } from "@backend/model/api/net.worth";
import { RestBody } from "@backend/model/api/rest.request";
import { TransactionRequest } from "@backend/model/api/transaction";
import { Transaction } from "@backend/model/transaction";
import { User } from "@backend/model/user";
import { format, isBefore, isSameDay, startOfDay, subDays, subYears } from "date-fns";
import { Dictionary } from "lodash";
import { LessThan } from "typeorm";
import { RestMetadata } from "../metadata";

export class TransactionAPI {
  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.get, "POST"))
  async getTransactions(request: RestBody, user: User) {
    const parsedRequest = TransactionRequest.fromPlain(request.payload);
    return await Transaction.find({ skip: parsedRequest.startIndex, take: parsedRequest.endIndex, where: { account: { user: { username: user.username } } } });
  }

  /** Returns the net-worth of all accounts  */
  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.getNetWorth, "GET"))
  async getNetWorth(_request: RestBody, user: User) {
    // Calculate net worth from all accounts
    const accounts = await Account.find({ where: { user: { id: user.id } } });
    return accounts.reduce((acc, account) => acc + account.balance, 0);
  }

  /** Returns various net-worth tracking over time */
  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.getNetWorthOverTime, "GET"))
  async getNetWorthOT(_request: RestBody, user: User) {
    const today = startOfDay(new Date());

    const sevenDaysAgo = subDays(today, 7);
    const thirtyDaysAgo = subDays(today, 30);
    const oneYearAgo = subYears(today, 1);

    const calculateNetWorthForDate = async (targetDate: Date): Promise<number> => {
      // If today is the day, we want current values, not account history
      let relevantAccountHistories: { accountId: string; balance: number }[];
      if (isSameDay(targetDate, new Date()))
        relevantAccountHistories = (await Account.find({ where: { user: { id: user.id } } })).map((x) => ({ accountId: x.id, balance: x.balance }));
      else
        relevantAccountHistories = (
          await AccountHistory.find({
            where: {
              account: { user: { id: user.id } },
              time: LessThan(targetDate),
            },
            order: { time: "DESC" },
          })
        ).map((x) => ({ accountId: x.account.id, balance: x.account.balance }));

      const latestBalancesPerAccount: { [accountId: string]: number } = {};
      const processedAccountIds: Set<string> = new Set();

      for (const history of relevantAccountHistories) {
        const accountId = history.accountId;

        if (!processedAccountIds.has(accountId)) {
          latestBalancesPerAccount[accountId] = history.balance;
          processedAccountIds.add(accountId);
        }
      }

      return Object.values(latestBalancesPerAccount).reduce((acc, balance) => acc + balance, 0);
    };

    const netWorthSevenDaysAgo = await calculateNetWorthForDate(sevenDaysAgo);
    const netWorthThirtyDaysAgo = await calculateNetWorthForDate(thirtyDaysAgo);
    const netWorthOneYearAgo = await calculateNetWorthForDate(oneYearAgo);

    const currentNetWorth = await calculateNetWorthForDate(today);

    const historicalData: Dictionary<number> = {};
    let currentDatePointer = startOfDay(oneYearAgo);

    while (isBefore(currentDatePointer, today) || currentDatePointer.getTime() === today.getTime()) {
      const formattedDate = format(currentDatePointer, "yyyy-MM-dd");
      historicalData[formattedDate] = await calculateNetWorthForDate(currentDatePointer);
      currentDatePointer = subDays(currentDatePointer, -1);
    }

    const todayFormatted = format(today, "yyyy-MM-dd");
    historicalData[todayFormatted] = currentNetWorth;

    return NetWorthOverTime.fromPlain({
      last7Days: currentNetWorth - netWorthSevenDaysAgo,
      last30Days: currentNetWorth - netWorthThirtyDaysAgo,
      lastYear: currentNetWorth - netWorthOneYearAgo,
      historicalData: historicalData,
    });
  }
}
