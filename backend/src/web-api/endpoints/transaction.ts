import { Account } from "@backend/model/account";
import { AccountHistory } from "@backend/model/account.history";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { NetWorthOverTime } from "@backend/model/api/net.worth";
import { RestBody } from "@backend/model/api/rest.request";
import { TransactionRequest } from "@backend/model/api/transaction";
import { Transaction } from "@backend/model/transaction";
import { User } from "@backend/model/user";
import { format, isBefore, startOfDay, subDays, subYears } from "date-fns";
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

    const calculateNetWorthForDate = async (date: Date): Promise<number> => {
      const accountBalancesAtDate = await AccountHistory.find({ where: { account: { user: { id: user.id } }, time: LessThan(date) }, order: { time: "DESC" } });

      return accountBalancesAtDate.reduce((acc, history) => {
        return acc + history.balance;
      }, 0);
    };

    // --- Calculate individual period changes ---
    const netWorthSevenDaysAgo = await calculateNetWorthForDate(sevenDaysAgo);
    const netWorthThirtyDaysAgo = await calculateNetWorthForDate(thirtyDaysAgo);
    const netWorthOneYearAgo = await calculateNetWorthForDate(oneYearAgo);

    const currentNetWorth = await calculateNetWorthForDate(today); // Get current net worth

    const historicalData: Dictionary<number> = {};
    let currentDatePointer = oneYearAgo; // Start from one year ago
    while (isBefore(currentDatePointer, today) || currentDatePointer.getTime() === today.getTime()) {
      const formattedDate = format(currentDatePointer, "yyyy-MM-dd"); // Use a consistent date format
      historicalData[formattedDate] = await calculateNetWorthForDate(currentDatePointer);
      currentDatePointer = subDays(currentDatePointer, -1); // Move to the next day
    }

    // Ensure current day's net worth is included if not already
    const todayFormatted = format(today, "yyyy-MM-dd");
    if (!historicalData[todayFormatted]) {
      historicalData[todayFormatted] = currentNetWorth;
    }

    return NetWorthOverTime.fromPlain({
      last7Days: currentNetWorth - netWorthSevenDaysAgo,
      last30Days: currentNetWorth - netWorthThirtyDaysAgo,
      lastYear: currentNetWorth - netWorthOneYearAgo,
      historicalData: historicalData,
    });
  }
}
