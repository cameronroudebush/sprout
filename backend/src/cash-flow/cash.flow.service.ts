import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { Category } from "@backend/category/model/category.model";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { endOfDay, endOfMonth, format, startOfDay, startOfMonth, subMonths } from "date-fns";
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

    // Fetch Transactions (Include 'account' to check for liabilities)
    const where = {
      account: { id: accountId, user: { id: user.id } },
      posted: between,
      pending: false,
    } as FindOptionsWhere<Transaction>;

    const transactions = await Transaction.find({ where, relations: ["category", "account"] });

    // Process Data
    const categoryStats = new Map<string, { category: Category; inflow: number; outflow: number }>();
    let totalIncome = 0;
    let totalExpense = 0;

    for (const transaction of transactions) {
      if (!transaction.category) continue;

      const catId = transaction.category.id;
      if (!categoryStats.has(catId)) {
        categoryStats.set(catId, { category: transaction.category, inflow: 0, outflow: 0 });
      }
      const stats = categoryStats.get(catId)!;

      const amount = transaction.amount;

      if (amount > 0) {
        // If money flows into an account, it is NOT income. It is ignored here.
        if (transaction.account && this.isLiabilityAccount(transaction.account)) continue;

        stats.inflow += amount;
        totalIncome += amount;
      } else {
        // Money leaving ANY account is treated as activity/expense
        const absAmount = Math.abs(amount);
        stats.outflow += absAmount;
        totalExpense += amount; // Keep negative for consistency if needed, or track abs
      }
    }

    // Find largest single expense (for insights)
    let largestExpense: Transaction | undefined;
    for (const transaction of transactions)
      if (transaction.amount < 0 && (largestExpense == null || transaction.amount < largestExpense.amount)) largestExpense = transaction;

    return { totalIncome, totalExpense: Math.abs(totalExpense), categoryStats, transactionCount: transactions.length, largestExpense };
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
      addOrUpdateLink(incomeHubName, target, netSavings, "You earned more than you spent this month! Good Job!");
      colors[target] = "#48BB78";
    } else if (netSavings < -0.01) {
      const source = "Deficit";
      addOrUpdateLink(source, incomeHubName, Math.abs(netSavings), "You spent more than you earned this month!");
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
}
