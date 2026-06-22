import { Configuration } from "@backend/config/core";
import { TimeZone } from "@backend/config/model/tz";
import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { Utility } from "@backend/core/model/utility/utility";
import { User } from "@backend/user/model/user.model";
import { subDays } from "date-fns";

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
  transactions: Array<{ description: string; category: string; amount: number; amountText: string }>;

  constructor(
    user: User,
    totalNetWorth: number,
    weeklyExpenses: number,
    weeklyIncome: number,
    transactionCount: number,
    transactions: Array<Omit<WeeklyEmailContent["transactions"][number], "amountText">>,
  ) {
    this.user = user.username;
    this.totalNetWorth = totalNetWorth;
    this.totalNetWorthText = CurrencyHelper.format(totalNetWorth, user);
    this.weeklyExpenses = CurrencyHelper.format(weeklyExpenses, user);
    this.weeklyIncomeText = CurrencyHelper.format(weeklyIncome, user);
    this.weeklyIncome = weeklyIncome;
    this.transactionCount = transactionCount;
    this.transactions = transactions.map((x) => {
      // Truncate the description so it's not so insanely long
      const max = Configuration.server.email.maxDescriptionLength;
      const description = x.description.length > max ? x.description.substring(0, max) + "..." : x.description;

      return {
        ...x,
        description,
        amountText: CurrencyHelper.format(x.amount, user),
      };
    });
  }
}
