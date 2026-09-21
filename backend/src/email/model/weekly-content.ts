import { Configuration } from "@backend/config/core";
import { TimeZone } from "@backend/config/model/tz";
import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { Utility } from "@backend/core/model/utility/utility";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { format, isSameDay, subDays } from "date-fns";

/** The content we provide to the weekly email update */
export class WeeklyEmailContent {
  /** A list of fun or insightful financial quotes */
  private static readonly quotes = [
    // Classics
    `"A penny saved, is a penny earned." - Benjamin Franklin`,
    `"Rule No. 1: Never lose money. Rule No. 2: Never forget rule No. 1." - Warren Buffett`,
    `"The safe way to double your money is to fold it over once and put it in your pocket." - Kin Hubbard`,
    `"There is a giant difference between earning a great deal of money and being rich." - Marlene Dietrich`,
    `"Too many people spend money they haven't earned, to buy things they don't want, to impress people they don't like." - Will Rogers`,
    // Mindset & Lifestyle
    `The goal isn't more money. The goal is living life on your terms.`,
    `Financial freedom is available to those who learn about it and work for it.`,
    `"Stop buying things you don't need, to impress people you don't like."`,
    `Investing in yourself is the best investment you will ever make.`,
    `Do not save what is left after spending, but spend what is left after saving.`,
    // Automation & Consistency
    `Small habits compounded over time create massive wealth.`,
    `The bit by bit accumulation of small savings is the foundation of wealth.`,
    `Wealth is not about having a lot of money; it's about having a lot of options.`,
  ];

  /** A list greetings */
  private static readonly greetings = ["Howdy", "Hi"];

  /** An inspiring quote */
  quote = Utility.randomFromArray(WeeklyEmailContent.quotes);
  greeting = Utility.randomFromArray(WeeklyEmailContent.greetings);
  today = TimeZone.formatDate(new Date(), "PPpp");
  oneWeekAgoDate = TimeZone.formatDate(subDays(new Date(), 7), "PPP");
  /** The users name */
  user: string;
  totalNetWorth: number;
  totalNetWorthText: string;
  weeklyExpenses: string;
  weeklyIncome: number;
  weeklyIncomeText: string;
  transactionCount: number;

  /** Daily spending chart metrics */
  dailySpendingBars: Array<{ label: string; amount: number; amountText: string; heightPercent: number }>;

  transactions: Array<{ description: string; category: string; amount: number; amountText: string; iconUrl?: string | null; pending?: boolean }>;

  constructor(user: User, totalNetWorth: number, weeklyExpenses: number, weeklyIncome: number, transactionCount: number, transactions: Array<Transaction>) {
    this.user = user.username;
    this.totalNetWorth = totalNetWorth;
    this.totalNetWorthText = CurrencyHelper.format(totalNetWorth, user);
    this.weeklyExpenses = CurrencyHelper.format(weeklyExpenses, user);
    this.weeklyIncomeText = CurrencyHelper.format(weeklyIncome, user);
    this.weeklyIncome = weeklyIncome;
    this.transactionCount = transactionCount;

    // Calculate daily expenses over the past 7 days
    const now = new Date();
    const days: Array<{ date: Date; total: number; label: string }> = [];
    for (let i = 6; i >= 0; i--) {
      const d = subDays(now, i);
      days.push({
        date: d,
        total: 0,
        label: format(d, "EEE"),
      });
    }

    transactions.forEach((tx) => {
      if (tx.amount < 0 && tx.posted) {
        const txDate = new Date(tx.posted);
        const dayMatch = days.find((d) => isSameDay(d.date, txDate));
        if (dayMatch) {
          dayMatch.total += Math.abs(tx.amount);
        }
      }
    });

    const maxExpense = Math.max(...days.map((d) => d.total), 1);
    this.dailySpendingBars = days.map((d) => ({
      label: d.label,
      amount: d.total,
      amountText: d.total > 0 ? CurrencyHelper.format(d.total, user) : "",
      // Days with 0 spending yield 0% height (no bar)
      heightPercent: d.total > 0 ? Math.max(Math.round((d.total / maxExpense) * 100), 8) : 0,
    }));

    // Map our transaction content
    this.transactions = transactions.map((x) => {
      const max = Configuration.server.email.maxDescriptionLength;
      const rawDescription = x.description ?? "";
      const description = rawDescription.length > max ? rawDescription.substring(0, max) + "..." : rawDescription;

      return {
        ...x,
        description,
        category: x.category?.name ?? "",
        amount: x.amount,
        amountText: CurrencyHelper.format(x.amount, user),
        iconUrl: Configuration.server.brandFetch.getWebsiteIconUrl(x.extra?.website),
      };
    });
  }
}
