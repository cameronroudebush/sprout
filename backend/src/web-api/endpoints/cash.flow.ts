import { CashFlowRequest } from "@backend/model/api/cash.flow";
import { CashFlowStats } from "@backend/model/api/cash.flow.stats";
import { RestEndpoints } from "@backend/model/api/endpoint";
import { RestBody } from "@backend/model/api/rest.request";
import { SankeyData, SankeyLink } from "@backend/model/api/sankey";
import { Category } from "@backend/model/category";
import { Transaction } from "@backend/model/transaction";
import { User } from "@backend/model/user";
import { FindOptionsWhere } from "typeorm";
import { RestMetadata } from "../metadata";

/** This API provides endpoints to help inform the interfaces of where money is going. */
export class CashFlowAPI {
  /**
   * A private helper method to perform all cash flow calculations.
   * This is the single source of truth for both endpoints.
   */
  private static async calculateFlows(flowRequest: CashFlowRequest, user: User) {
    const where = {
      account: { id: flowRequest.account?.id, user: { id: user.id } },
      posted: flowRequest.between,
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
   * Returns the cash flow information formatted for a Sankey diagram.
   */
  @RestMetadata.register(new RestMetadata(RestEndpoints.cashFlow.get, "GET"))
  async get(request: RestBody<CashFlowRequest>, user: User): Promise<SankeyData> {
    const flowRequest = CashFlowRequest.fromPlain(request.payload);
    flowRequest.validate();

    // Call the single source of truth for all data.
    const { netTotals, totalExpense } = await CashFlowAPI.calculateFlows(flowRequest, user);

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

  /**
   * Returns cash flow stats that informs on how much we brought in and how much went out.
   */
  @RestMetadata.register(new RestMetadata(RestEndpoints.cashFlow.stats, "GET"))
  async getStats(request: RestBody<CashFlowRequest>, user: User) {
    const flowRequest = CashFlowRequest.fromPlain(request.payload);
    flowRequest.validate();
    const { totalIncome, totalExpense, transactionCount, largestExpense } = await CashFlowAPI.calculateFlows(flowRequest, user);
    return new CashFlowStats(totalExpense, totalIncome, transactionCount, largestExpense ?? undefined);
  }
}
