import { TimeZone } from "@backend/config/model/tz";
import { Utility } from "@backend/core/model/utility/utility";
import { User } from "@backend/user/model/user.model";
import { subDays } from "date-fns";

/** The content we provide to the weekly email update */
export class WeeklyEmailContent {
  /** A list of fun or insightful financial quotes */
  private static readonly quotes = [
    // Actual quotes
    `"A penny saved, is a penny earned." - Benjamin Franklin`,
    `"Rule No. 1: Never lose money. Rule No. 2: Never forget rule No. 1." - Warren Buffett`,
    // Other sayings
    `The goal isn't more money. The goal is living life on your terms.`,
    `Financial freedom is available to those who learn about it and work for it.`,
    `"Stop buying things you don't need, to impress people you don't like."`,
    `Investing in yourself is the best investment you will ever make.`,
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
    this.totalNetWorthText = `$${totalNetWorth.toLocaleString(undefined, { minimumFractionDigits: 2 })}`;
    this.weeklyExpenses = `$${weeklyExpenses.toLocaleString(undefined, { minimumFractionDigits: 2 })}`;
    this.weeklyIncomeText = `$${weeklyIncome.toLocaleString(undefined, { minimumFractionDigits: 2 })}`;
    this.weeklyIncome = weeklyIncome;
    this.transactionCount = transactionCount;
    this.transactions = transactions.map((x) => ({ ...x, amountText: x.amount.toLocaleString(undefined, { minimumFractionDigits: 2 }) }));
  }

  /** Returns an instance of `this` with fake data */
  static asFake() {
    return new WeeklyEmailContent({ username: "Demo" } as User, 142550.0, 450.25, 500, 12, [
      { description: "Grocery Store", category: "shopping", amount: -85.2 },
      { description: "Utility Bill", category: "utilities", amount: -120.0 },
      { description: "Freelance Payout", category: "paycheck", amount: 500.0 },
    ]);
  }
}
