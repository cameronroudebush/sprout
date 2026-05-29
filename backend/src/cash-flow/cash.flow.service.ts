import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { DailySpendingCalendarResponseDTO, DailySpendingItem } from "@backend/cash-flow/model/api/daily.spending.dto";
import { Category } from "@backend/category/model/category.model";
import { HistoricalDataPoint } from "@backend/net-worth/model/api/entity.history.dto";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import {
  eachDayOfInterval,
  eachMonthOfInterval,
  endOfDay,
  endOfMonth,
  endOfYear,
  format,
  isSameDay,
  isSameMonth,
  startOfDay,
  startOfMonth,
  startOfYear,
  subMonths,
} from "date-fns";
import { Between, FindOptionsWhere } from "typeorm";
import { CashFlowSpending, MonthlySpendingStats } from "./model/api/cash.flow.spending.dto";
import { SankeyData, SankeyLink } from "./model/api/sankey.dto";
import { Colors } from "./model/colors";

@Injectable()
export class CashFlowService {
  /**
   * Helper to determine if an account behaves as a Liability.
   * Inflows to these accounts (e.g. paying off a credit card or mortgage)
   * are NOT income; they are debt reduction.
   */
  private isLiabilityAccount(account: Account): boolean {
    switch (account.type) {
      case AccountType.loan:
      case AccountType.credit:
        return true;
      default:
        return false;
    }
  }

  /**
   * Core calculation engine.
   * Aggregates transactions into Inflow/Outflow per category.
   */
  async calculateFlows(user: User, year: number, month?: number, day?: number, accountId?: string) {
    if (month) month -= 1; // Adjust to 0-index
    let between;
    if (month == null) {
      between = Between(new Date(year, 0, 1), new Date(year, 11, 31, 23, 59, 59, 999));
    } else {
      const queryDate = new Date(year, month, day ?? 1);
      between = day == null ? Between(startOfMonth(queryDate), endOfMonth(queryDate)) : Between(startOfDay(queryDate), endOfDay(queryDate));
    }

    // Fetch Transactions
    const where = {
      account: { id: accountId, user: { id: user.id } },
      posted: between,
      pending: false,
    } as FindOptionsWhere<Transaction>;

    const transactions = Transaction.convertListToTargetCurrency(await Transaction.find({ where, relations: ["category", "account"] }), user);

    const categoryStats = new Map<string, { category: Category; inflow: number; outflow: number }>();

    for (const transaction of transactions) {
      if (!transaction.category) continue;

      const catId = transaction.category.id;
      if (!categoryStats.has(catId)) {
        categoryStats.set(catId, { category: transaction.category, inflow: 0, outflow: 0 });
      }
      const stats = categoryStats.get(catId)!;
      let amount = transaction.amount;
      const isInvestment = transaction.account && transaction.account.type === AccountType.investment;

      const isContributionCategory =
        transaction.category.name.toLowerCase().includes("contribution") || transaction.category.name.toLowerCase().includes("investment");

      // Invert the amount if it is a negative value AND explicitly a contribution. Some contributions will technically be considered negative which could break this
      if (isInvestment && amount < 0 && isContributionCategory) amount = Math.abs(amount);

      if (amount > 0) {
        // Liability check: Inflows to liability accounts (e.g. credit card payments) are ignored here.
        if (transaction.account && this.isLiabilityAccount(transaction.account)) continue;
        stats.inflow += amount;
      } else {
        stats.outflow += Math.abs(amount);
      }
    }

    // We calculate totals based on the NET result of each category.
    let totalIncome = 0;
    let totalExpense = 0;

    for (const { inflow, outflow } of categoryStats.values()) {
      const net = inflow - outflow;

      if (net > 0) {
        // Net Income (e.g. Salary, or Refunds > Spending)
        totalIncome += net;
      } else {
        // Net Expense (e.g. Groceries, Rent)
        totalExpense += Math.abs(net);
      }
    }

    // Find largest single expense (for insights) - remains purely transaction-based
    let largestExpense: Transaction | undefined;
    for (const transaction of transactions) {
      if (transaction.amount < 0 && (largestExpense == null || transaction.amount < largestExpense.amount)) {
        largestExpense = transaction;
      }
    }

    return { totalIncome, totalExpense, categoryStats, transactionCount: transactions.length, largestExpense };
  }

  /**
   * Generates the Sankey Diagram using Net Flow logic.
   * Transfers and Refunds are handled automatically by netting In vs Out.
   */
  async buildSankey(user: User, year: number, month?: number, day?: number, accountId?: string) {
    const { categoryStats } = await this.calculateFlows(user, year, month, day, accountId);

    // Load full category tree for path mapping
    const categories = await Category.find({ where: { user: { id: user.id } }, relations: ["parentCategory"] });
    const categoryMap = new Map<string, Category>(categories.map((c) => [c.id, c]));

    const incomeHubName = "Inflows";
    const linksMap = new Map<string, SankeyLink>();
    const colors: SankeyData["colors"] = { [incomeHubName]: Colors.incomeColor };

    // Helper to add links
    const addOrUpdateLink = (source: string, target: string, value: number, description?: string) => {
      const cleanSource = source;
      const cleanTarget = target;
      if (cleanSource === cleanTarget || value <= 0.01) return;

      const key = `${cleanSource}|${cleanTarget}`;
      const existingLink = linksMap.get(key);

      if (existingLink) existingLink.value += value;
      else {
        linksMap.set(key, new SankeyLink(cleanSource, cleanTarget, value, description));
        if (!colors[cleanSource]) colors[cleanSource] = Colors.getColorForFeature(cleanSource);
        if (cleanTarget !== incomeHubName && !colors[cleanTarget]) colors[cleanTarget] = Colors.getColorForFeature(cleanTarget);
      }
    };

    // Helper to walk up the category tree
    const getCategoryPath = (leafCategory: Category): Category[] => {
      const path: Category[] = [leafCategory];
      let current = leafCategory;
      while (current.parentCategoryId) {
        const parent = categoryMap.get(current.parentCategoryId);
        if (parent) {
          path.unshift(parent);
          current = parent;
        } else break;
      }
      return path;
    };

    let netSavings = 0;

    for (const { category, inflow, outflow } of categoryStats.values()) {
      const net = inflow - outflow;

      // Skip balanced transfers (e.g. Checking -> Savings, where net is 0)
      if (Math.abs(net) < 0.01) continue;

      if (net > 0) {
        // NET INCOME
        // Example: Salary, or Refunds > Spending
        let sourceName = `${category.name} `; // We add a space at the end, just in case there is an overlap on in vs out
        if (sourceName.trim() === incomeHubName) sourceName = `${sourceName} `;

        addOrUpdateLink(sourceName, incomeHubName, net);
        netSavings += net;
      } else {
        // NET EXPENSE
        // Example: Mortgage, Groceries
        const absNet = Math.abs(net);
        const path = getCategoryPath(category);

        let currentSourceName = incomeHubName;
        for (const node of path) {
          addOrUpdateLink(currentSourceName, node.name, absNet);
          currentSourceName = node.name;
        }
        netSavings -= absNet;
      }
    }

    // Handle Surplus / Deficit Nodes
    if (netSavings > 0.01) {
      const target = "Savings / Unallocated";
      addOrUpdateLink(incomeHubName, target, netSavings, "You earned more than you spent! Good Job!");
      colors[target] = "#48BB78";
    } else if (netSavings < -0.01) {
      const source = "Deficit";
      addOrUpdateLink(source, incomeHubName, Math.abs(netSavings), "You spent more than you earned!");
      colors[source] = "#F56565";
    }

    // Sort and Format Output
    const allLinks = Array.from(linksMap.values());
    const inputLinks = allLinks.filter((l) => l.target === incomeHubName).sort((a, b) => b.value - a.value);
    const outputLinks = allLinks.filter((l) => l.target !== incomeHubName).sort((a, b) => b.value - a.value);

    const sortedLinks = [...inputLinks, ...outputLinks];
    const nodeSet = new Set<string>();
    allLinks.forEach((l) => {
      nodeSet.add(l.source);
      nodeSet.add(l.target);
    });

    return new SankeyData(Array.from(nodeSet), sortedLinks, colors);
  }

  /**
   * Calculates monthly spending history.
   * Reuses calculateFlows to ensure the numbers match the Sankey.
   */
  async calculateMonthlySpending(user: User, months: number, categoriesLimit: number) {
    const today = new Date();
    const monthlyStatsMap = new Map<string, MonthlySpendingStats>();
    const globalCategoryTotals = new Map<string, number>();
    let totalPeriodSpending = 0;

    for (let i = 0; i < months; i++) {
      const targetDate = subMonths(today, i);
      const year = targetDate.getFullYear();
      const month = targetDate.getMonth() + 1;

      // Reuse the main calculator
      const { categoryStats } = await this.calculateFlows(user, year, month);

      const monthKey = format(targetDate, "yyyy-MM");
      const stats: MonthlySpendingStats = {
        monthLabel: format(targetDate, "MMM").toUpperCase(),
        date: targetDate,
        categories: [],
        totalSpending: 0,
        periodAverage: 0,
      };

      const currentMonthCats = new Map<string, number>();

      for (const { category, outflow, inflow } of categoryStats.values()) {
        // Calculate Net Expense for this category
        // If (Outflow - Inflow) is positive, it's a Net Spend.
        const netSpend = outflow - inflow;

        if (netSpend < 0.01) continue; // Skip income categories or refunds

        stats.totalSpending += netSpend;
        totalPeriodSpending += netSpend;

        const catName = category.name;
        currentMonthCats.set(catName, (currentMonthCats.get(catName) || 0) + netSpend);
        globalCategoryTotals.set(catName, (globalCategoryTotals.get(catName) || 0) + netSpend);
      }

      monthlyStatsMap.set(monthKey, stats);
      (stats as any)._rawCategories = currentMonthCats;
    }

    // Determine Top Categories
    const sortedCategories = Array.from(globalCategoryTotals.entries()).sort((a, b) => b[1] - a[1]);
    const topCategoryNames = sortedCategories.slice(0, categoriesLimit).map((e) => e[0]);
    const topCategoriesSet = new Set(topCategoryNames);

    const periodAverage = totalPeriodSpending / months;

    // Finalize Results
    const results = Array.from(monthlyStatsMap.values()).map((stats) => {
      stats.periodAverage = periodAverage;
      const rawCats = (stats as any)._rawCategories as Map<string, number>;
      const finalCatMap = new Map<string, number>();

      for (const [name, amount] of rawCats.entries()) {
        const displayName = topCategoriesSet.has(name) ? name : "Other";
        finalCatMap.set(displayName, (finalCatMap.get(displayName) || 0) + amount);
      }

      stats.categories = Array.from(finalCatMap.entries()).map(([name, amount]) => ({
        name,
        amount,
        color: Colors.getColorForFeature(name),
      }));

      stats.categories.sort((a, b) => (a.name === "Other" ? 1 : b.name === "Other" ? -1 : b.amount - a.amount));
      delete (stats as any)._rawCategories;
      return stats;
    });

    results.sort((a, b) => a.date.getTime() - b.date.getTime());

    return new CashFlowSpending(results, topCategoryNames);
  }

  /**
   * Compares the current scope against a provided target (Daily mapping over a month or Monthly mapping over a year).
   */
  async getSpendingTimeline(user: User, year: number, month?: number) {
    const isMonthlyMode = month !== undefined && month !== null;

    const startDate = isMonthlyMode ? startOfMonth(new Date(year, month - 1)) : startOfYear(new Date(year, 0));
    const endDate = isMonthlyMode ? endOfMonth(startDate) : endOfYear(startDate);

    const transactions = Transaction.convertListToTargetCurrency(
      await Transaction.find({
        where: {
          account: { user: { id: user.id } },
          posted: Between(startDate, endDate),
          pending: false,
        },
        relations: ["category", "account"],
      }),
      user,
    );

    const accumulatedTotals: HistoricalDataPoint[] = [];
    let runningTotal = 0;

    if (isMonthlyMode) {
      // Run Daily Cumulative Aggregation over a target month range window
      const days = eachDayOfInterval({ start: startDate, end: endDate });
      for (const day of days) {
        const dailyExpense = transactions
          .filter((t) => isSameDay(t.posted, day) && t.amount < 0 && !this.isLiabilityAccount(t.account))
          .reduce((sum, t) => sum + Math.abs(t.amount), 0);

        runningTotal += dailyExpense;
        accumulatedTotals.push(new HistoricalDataPoint(day, runningTotal));
      }
    } else {
      // Run Monthly Cumulative Aggregation over a target fiscal year scope window
      const months = eachMonthOfInterval({ start: startDate, end: endDate });
      for (const m of months) {
        const monthlyExpense = transactions
          .filter((t) => isSameMonth(t.posted, m) && t.amount < 0 && !this.isLiabilityAccount(t.account))
          .reduce((sum, t) => sum + Math.abs(t.amount), 0);

        runningTotal += monthlyExpense;
        accumulatedTotals.push(new HistoricalDataPoint(m, runningTotal));
      }
    }

    return accumulatedTotals;
  }

  /**
   * Calculates discrete daily spending totals for a specified month and year.
   * Returns a key-value record mapping the day of the month to its total expenditure.
   */
  async getDailySpendingMap(user: User, year: number, month: number) {
    const startDate = startOfMonth(new Date(year, month - 1));
    const endDate = endOfMonth(startDate);

    const transactions = Transaction.convertListToTargetCurrency(
      await Transaction.find({
        where: {
          account: { user: { id: user.id } },
          posted: Between(startDate, endDate),
          pending: false,
        },
        relations: ["account"],
      }),
      user,
    );

    const items: DailySpendingItem[] = [];
    const days = eachDayOfInterval({ start: startDate, end: endDate });

    for (const day of days) {
      const dayNumber = day.getDate();

      const totalSpentToday = transactions
        .filter((t) => isSameDay(t.posted, day) && t.amount < 0 && !this.isLiabilityAccount(t.account))
        .reduce((sum, t) => sum + Math.abs(t.amount), 0);

      if (totalSpentToday > 0) items.push(new DailySpendingItem(dayNumber, totalSpentToday));
    }
    return new DailySpendingCalendarResponseDTO(items);
  }
}
