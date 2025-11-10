import { Category } from "@backend/category/model/category.model";
import { CategoryType } from "@backend/category/model/category.type";
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
        // Only set color for target if it's not the incomeHub (to preserve its fixed color)
        if (cleanTarget !== incomeHubName && !colors[cleanTarget]) colors[cleanTarget] = getNextColor();
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
}
