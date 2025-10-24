import { Category } from "@backend/category/model/category.model";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { endOfDay, endOfMonth, startOfDay, startOfMonth } from "date-fns";
import { Between, FindOptionsWhere } from "typeorm";
import { SankeyData, SankeyLink } from "./model/api/sankey.dto";

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

      if (category.type === "income") {
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
    const { netTotals, totalExpense } = await this.calculateFlows(user, year, month, day, accountId);

    const categories = await Category.find({ where: { userId: user.id }, relations: ["parentCategory"] });
    const categoryMap = new Map<string, Category>(categories.map((c) => [c.id, c]));

    const incomeHubName = "Income";
    const linksMap = new Map<string, SankeyLink>();
    const colors: SankeyData["colors"] = {
      [incomeHubName]: SankeyData.incomeColor,
    };

    let colorIndex = 0;
    const getNextColor = () => SankeyData.colors[colorIndex++ % SankeyData.colors.length]!;

    const addOrUpdateLink = (source: string, target: string, value: number) => {
      const cleanSource = source.trim();
      const cleanTarget = target.trim();
      if (cleanSource === cleanTarget || value <= 0) return;

      const key = `${cleanSource}|${cleanTarget}`;
      const existingLink = linksMap.get(key);

      if (existingLink) existingLink.value += value;
      else {
        linksMap.set(key, new SankeyLink(cleanSource, cleanTarget, value));
        if (!colors[cleanSource]) colors[cleanSource] = getNextColor();
        if (!colors[cleanTarget]) colors[cleanTarget] = getNextColor();
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

    // Build the links for the diagram from the net totals.
    for (const { category, amount } of netTotals.values()) {
      const absAmount = Math.abs(amount);
      if (absAmount < 0.01) continue;

      if (category.type === "income") {
        if (amount > 0) {
          let sourceName = category.name;
          if (sourceName.trim() === incomeHubName) sourceName = `${sourceName} (Source)`;
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

    const totalExpenseAbs = Math.abs(totalExpense);
    if (totalExpenseAbs > 0) addOrUpdateLink(incomeHubName, incomeHubName, totalExpenseAbs);

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
}
