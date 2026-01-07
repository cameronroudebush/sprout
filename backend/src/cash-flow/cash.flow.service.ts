import { Category } from "@backend/category/model/category.model";
import { CategoryType } from "@backend/category/model/category.type";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { endOfDay, endOfMonth, format, startOfDay, startOfMonth, subMonths } from "date-fns";
import { Between, FindOptionsWhere, LessThan } from "typeorm";
import { CashFlowSpending, MonthlySpendingStats } from "./model/api/cash.flow.spending.dto";
import { SankeyData, SankeyLink } from "./model/api/sankey.dto";
import { Colors } from "./model/colors";

/** This service contains re-usable functions for calculating cash flow. */
@Injectable()
export class CashFlowService {
  /**
   * A helper method to perform all cash flow calculations. Given a query list of params
   *   will determine the cash flow for the sankey diagram.
   */
  async calculateFlows(user: User, year: number, month?: number, day?: number, accountId?: string) {
    // Adjust month so it's 0 index
    if (month) month -= 1;
    let between;
    if (month == null) {
      // If no month is given, include the entire year
      between = Between(new Date(year, 0, 1), new Date(year, 11, 31, 23, 59, 59, 999));
    } else {
      const queryDate = new Date(year, month, day ?? 1);
      between = day == null ? Between(startOfMonth(queryDate), endOfMonth(queryDate)) : Between(startOfDay(queryDate), endOfDay(queryDate));
    }

    const where = {
      account: { id: accountId, user: { id: user.id } },
      posted: between,
      pending: false,
    } as FindOptionsWhere<Transaction>;

    const transactions = await Transaction.find({ where, relations: ["category"] });

    // Aggregate transactions by category.
    const netTotals = new Map<string, { category: Category; amount: number }>();
    for (const transaction of transactions) {
      if (!transaction.category) continue;

      const categoryId = transaction.category.id;
      const existing = netTotals.get(categoryId);
      if (existing) {
        existing.amount += transaction.amount;
      } else {
        netTotals.set(categoryId, { category: transaction.category, amount: transaction.amount });
      }
    }

    let totalIncome = 0;
    let totalExpense = 0;

    // Re-classify net totals into final income/expense buckets.
    for (const { category, amount } of netTotals.values()) {
      if (Math.abs(amount) < 0.01) continue;

      if (category.type === CategoryType.income) {
        if (amount > 0) totalIncome += amount;
        else totalExpense += amount; // Deductions are expenses.
      } else {
        // 'expense'
        if (amount < 0) totalExpense += amount;
        else totalIncome += amount; // Refunds are income.
      }
    }

    // Find largest single expense transaction.
    let largestExpense: Transaction | undefined;
    for (const transaction of transactions)
      if (transaction.amount < 0 && (largestExpense == null || transaction.amount < largestExpense.amount)) largestExpense = transaction;
    const transactionCount = transactions.length;
    return { totalIncome, totalExpense, netTotals, transactionCount, largestExpense };
  }

  /**
   * This function, given some parameters, generates the sankey diagram data utilizing {@link calculateFlows}
   */
  async buildSankey(user: User, year: number, month?: number, day?: number, accountId?: string) {
    const { netTotals } = await this.calculateFlows(user, year, month, day, accountId);

    const categories = await Category.find({ where: { user: { id: user.id } }, relations: ["parentCategory"] });
    const categoryMap = new Map<string, Category>(categories.map((c) => [c.id, c]));

    const incomeHubName = "Inflows";
    const linksMap = new Map<string, SankeyLink>();
    const colors: SankeyData["colors"] = {
      [incomeHubName]: Colors.incomeColor,
    };

    const addOrUpdateLink = (source: string, target: string, value: number) => {
      const cleanSource = source.trim();
      const cleanTarget = target.trim();
      if (cleanSource === cleanTarget || value <= 0) return;

      const key = `${cleanSource}|${cleanTarget}`;
      const existingLink = linksMap.get(key);

      if (existingLink) existingLink.value += value;
      else {
        linksMap.set(key, new SankeyLink(cleanSource, cleanTarget, value));
        if (!colors[cleanSource]) colors[cleanSource] = Colors.getColorForFeature(cleanSource);
        // Only set color for target if it's not the incomeHub (to preserve its fixed color)
        if (cleanTarget !== incomeHubName && !colors[cleanTarget]) colors[cleanTarget] = Colors.getColorForFeature(cleanTarget);
      }
    };

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

    // Calculate the total actual inflow and outflow of the Income hub
    let totalInflow = 0;
    let totalOutflow = 0;

    for (const { category, amount } of netTotals.values()) {
      const absAmount = Math.abs(amount);
      if (absAmount < 0.01) continue;

      if (category.type === CategoryType.income) {
        if (amount > 0) {
          // Positive Income (flows IN to Income Hub)
          totalInflow += absAmount;
        } else {
          // Income Deduction (flows OUT from Income Hub)
          totalOutflow += absAmount;
        }
      } else {
        // Expense Category
        if (amount < 0) {
          // Expense (flows OUT from Income Hub)
          totalOutflow += absAmount;
        } else {
          // Refund/Reimbursement (flows IN to Income Hub)
          totalInflow += absAmount;
        }
      }
    }

    const netDifference = totalInflow - totalOutflow;
    const deficit = netDifference < 0 ? Math.abs(netDifference) : 0;

    // Inject Deficit Link if necessary
    if (deficit > 0) {
      const deficitSourceName = "Deficit";
      // Add the deficit as a new source flow into the Income hub
      addOrUpdateLink(deficitSourceName, incomeHubName, deficit);
      // Set a distinct color for the deficit source node (e.g., red/orange)
      colors[deficitSourceName] = "#F56565";
    }

    // Build the links for the diagram from the net totals
    for (const { category, amount } of netTotals.values()) {
      const absAmount = Math.abs(amount);
      if (absAmount < 0.01) continue;

      if (category.type === CategoryType.income) {
        if (amount > 0) {
          let sourceName = category.name;
          if (sourceName.trim() === incomeHubName) sourceName = `${sourceName}`;
          addOrUpdateLink(sourceName, incomeHubName, absAmount);
        } else {
          const adjustedCatName = `${category.name} (Deduction)`;
          addOrUpdateLink(incomeHubName, adjustedCatName, absAmount);
        }
      } else {
        // 'expense'
        if (amount < 0) {
          const path = getCategoryPath(category);
          let currentSourceName = incomeHubName;
          for (const node of path) {
            addOrUpdateLink(currentSourceName, node.name, absAmount);
            currentSourceName = node.name;
          }
        } else {
          const adjustedCatName = `${category.name} (Refund)`;
          addOrUpdateLink(adjustedCatName, incomeHubName, absAmount);
        }
      }
    }

    const links = Array.from(linksMap.values());
    // Derive the nodes directly from the links for perfect accuracy
    const nodesSet = new Set<string>();
    nodesSet.add(incomeHubName); // Ensure Income hub is always present
    for (const link of links) {
      nodesSet.add(link.source);
      nodesSet.add(link.target);
    }
    const nodes = Array.from(nodesSet);

    return new SankeyData(nodes, links, colors);
  }

  /**
   * This function calculates the monthly spending for the given information within the date range provided. This allows
   *  us to see how the users spending tracks over time
   *
   * @param user The user we want the spending data for.
   * @param months How many months back to calculate for, assuming the current date as a starting pont.
   * @param categoriesLimit How many categories to include in the category separation. We will always provide +1 of this number for "other" categories.
   */
  async calculateMonthlySpending(user: User, months: number, categoriesLimit: number) {
    // Calc date range of what data we are looking for
    const today = new Date();
    const startDate = startOfMonth(subMonths(today, months - 1));
    const endDate = endOfMonth(today);

    // Fetch Transactions, only include expenses
    const transactions = await Transaction.find({
      where: {
        account: { user: { id: user.id } },
        posted: Between(startDate, endDate),
        amount: LessThan(0),
      },
      relations: ["category"], // Load category data info
    });

    // Calculate Global Category Totals
    const categoryTotals = new Map<string, number>();
    /** The total spending for all expenses within this range */
    let totalPeriodSpending = 0;

    transactions.forEach((t) => {
      const catName = t.category?.name || "Uncategorized";
      const amount = Math.abs(t.amount); // Convert to positive for display

      categoryTotals.set(catName, (categoryTotals.get(catName) || 0) + amount);
      totalPeriodSpending += amount;
    });

    // Sort to find Top N categories
    const sortedCategories = Array.from(categoryTotals.entries()).sort((a, b) => b[1] - a[1]);
    const topCategoryNames = sortedCategories.slice(0, categoriesLimit).map((entry) => entry[0]);
    const topCategoriesSet = new Set(topCategoryNames);

    const averagePerMonth = totalPeriodSpending / months;

    // Group by Month
    const monthlyMap = new Map<string, MonthlySpendingStats>();
    for (let i = 0; i < months; i++) {
      const d = subMonths(today, i);
      const key = format(d, "yyyy-MM");
      monthlyMap.set(key, {
        monthLabel: format(d, "MMM").toUpperCase(), // "JAN", "FEB", etc.
        date: d,
        categories: [],
        totalSpending: 0,
        periodAverage: averagePerMonth,
      });
    }

    // Aggregate monthly data
    const monthCatTracker = new Map<string, Map<string, number>>();
    transactions.forEach((t) => {
      const monthKey = format(t.posted, "yyyy-MM");
      const rawCatName = t.category?.name || "Uncategorized";
      // If it's a top category, keep name. Otherwise, group into "Other".
      const displayCatName = topCategoriesSet.has(rawCatName) ? rawCatName : "Other";
      const amount = Math.abs(t.amount);
      // Add to month total
      const monthStat = monthlyMap.get(monthKey)!;
      monthStat.totalSpending += amount;
      // Add to category breakdown
      if (!monthCatTracker.has(monthKey)) monthCatTracker.set(monthKey, new Map<string, number>());
      const catMap = monthCatTracker.get(monthKey)!;
      catMap.set(displayCatName, (catMap.get(displayCatName) || 0) + amount);
    });

    // Convert back to DTO
    const results = Array.from(monthlyMap.entries())
      .map(([key, stats]) => {
        const catMap = monthCatTracker.get(key);
        if (catMap)
          stats.categories = Array.from(catMap.entries()).map(([name, amount]) => ({
            name,
            amount,
            color: Colors.getColorForFeature(name),
          }));
        else stats.categories = [];

        // Sort categories so "Other" is always last
        stats.categories.sort((a, b) => {
          if (a.name === "Other") return 1;
          if (b.name === "Other") return -1;
          return b.amount - a.amount;
        });

        return stats;
      })
      .sort((a, b) => a.date.getTime() - b.date.getTime()); // Ensure chronological order
    return new CashFlowSpending(results, topCategoryNames);
  }
}
