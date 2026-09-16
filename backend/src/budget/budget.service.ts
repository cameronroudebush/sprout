import { BudgetHistoryResponseDto, MonthlyCategoryBudgetPerformance } from "@backend/budget/model/api/budget.history.dto";
import { BudgetOverviewResponseDto, CategoryBudgetOverviewItem } from "@backend/budget/model/api/budget.overview.dto";
import { CreateBudgetDto } from "@backend/budget/model/api/create.budget.dto";
import { UpdateBudgetDto } from "@backend/budget/model/api/update.budget.dto";
import { Budget } from "@backend/budget/model/budget.model";
import { CashFlowService } from "@backend/cash-flow/cash.flow.service";
import { Category } from "@backend/category/model/category.model";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from "@nestjs/common";
import { subMonths } from "date-fns";

@Injectable()
export class BudgetService {
  constructor(private readonly cashFlowService: CashFlowService) {}

  private checkBudgetingEnabled(user: User) {
    if (user.config && user.config.enableBudgeting === false) {
      throw new ForbiddenException("Budgeting feature is disabled in user settings.");
    }
  }

  /** Retrieve all configured budget targets for the given user */
  async getAllBudgets(user: User): Promise<Budget[]> {
    this.checkBudgetingEnabled(user);
    const budgets = await Budget.find({
      where: { user: { id: user.id } },
      relations: { category: true },
      order: { category: { name: "ASC" } },
    });
    return Budget.convertListToTargetCurrency(budgets, user);
  }

  /** Create a new budget target for a category */
  async createBudget(user: User, dto: CreateBudgetDto): Promise<Budget> {
    this.checkBudgetingEnabled(user);
    const category = await Category.findOne({ where: { id: dto.categoryId, user: { id: user.id } } });
    if (!category) {
      throw new NotFoundException(`Category with ID ${dto.categoryId} not found.`);
    }

    const existingBudget = await Budget.findOne({
      where: { user: { id: user.id }, category: { id: dto.categoryId } },
    });
    if (existingBudget) {
      throw new BadRequestException(`A budget already exists for category ${category.name}.`);
    }

    const budget = new Budget(user, category, dto.amount);
    await budget.insert();
    return budget;
  }

  /** Update an existing budget target */
  async updateBudget(user: User, budgetId: string, dto: UpdateBudgetDto): Promise<Budget> {
    this.checkBudgetingEnabled(user);
    const budget = await Budget.findOne({
      where: { id: budgetId, user: { id: user.id } },
      relations: { category: true },
    });
    if (!budget) {
      throw new NotFoundException(`Budget with ID ${budgetId} not found.`);
    }

    budget.amount = dto.amount;
    await budget.update();
    return budget;
  }

  /** Delete a budget target */
  async deleteBudget(user: User, budgetId: string): Promise<void> {
    this.checkBudgetingEnabled(user);
    const budget = await Budget.findOne({ where: { id: budgetId, user: { id: user.id } } });
    if (!budget) {
      throw new NotFoundException(`Budget with ID ${budgetId} not found.`);
    }
    await budget.remove();
  }

  /**
   * Generates a budget overview for a specific month and year.
   * Leverages CashFlowService.calculateFlows for database aggregated spending per category.
   */
  async getBudgetOverview(user: User, year?: number, month?: number): Promise<BudgetOverviewResponseDto> {
    this.checkBudgetingEnabled(user);
    const now = new Date();
    const targetYear = year ?? now.getFullYear();
    const targetMonth = month ?? now.getMonth() + 1;

    const budgets = await Budget.find({
      where: { user: { id: user.id } },
      relations: { category: true },
    });
    Budget.convertListToTargetCurrency(budgets, user);

    const budgetMap = new Map<string, Budget>();
    budgets.forEach((b) => {
      if (b.category) budgetMap.set(b.category.id, b);
    });

    const { categoryStats } = await this.cashFlowService.calculateFlows(user, targetYear, targetMonth);

    const items: CategoryBudgetOverviewItem[] = [];
    let totalBudgeted = 0;
    let totalSpent = 0;
    let totalOverBudgetAmount = 0;

    const processedCategoryIds = new Set<string>();

    for (const budget of budgets) {
      if (!budget.category) continue;
      const catId = budget.category.id;
      processedCategoryIds.add(catId);

      const stats = categoryStats.get(catId);
      const actualSpent = stats ? stats.outflow : 0;
      const budgetedAmount = budget.amount;

      totalBudgeted += budgetedAmount;
      totalSpent += actualSpent;

      if (actualSpent > budgetedAmount) {
        totalOverBudgetAmount += actualSpent - budgetedAmount;
      }

      items.push(new CategoryBudgetOverviewItem(budget.category, budgetedAmount, actualSpent, budget.id));
    }

    // Include categories that have non-zero spending even if no budget target was explicitly set
    for (const [catId, stats] of categoryStats.entries()) {
      if (processedCategoryIds.has(catId)) continue;
      if (stats.outflow > 0 && !stats.category.excludeFromCashFlow) {
        totalSpent += stats.outflow;
        totalOverBudgetAmount += stats.outflow;
        items.push(new CategoryBudgetOverviewItem(stats.category, 0, stats.outflow));
      }
    }

    items.sort((a, b) => b.budgetedAmount - a.budgetedAmount || b.actualSpent - a.actualSpent);

    return new BudgetOverviewResponseDto(targetYear, targetMonth, totalBudgeted, totalSpent, totalOverBudgetAmount, items);
  }

  /**
   * Retrieves historical monthly budget performance looking backwards in time.
   */
  async getBudgetHistory(user: User, months = 6, categoryId?: string): Promise<BudgetHistoryResponseDto> {
    this.checkBudgetingEnabled(user);
    const today = new Date();
    const history: MonthlyCategoryBudgetPerformance[] = [];

    let targetBudgets: Budget[] = [];
    if (categoryId) {
      const budget = await Budget.findOne({
        where: { user: { id: user.id }, category: { id: categoryId } },
        relations: { category: true },
      });
      if (budget) targetBudgets = [budget];
    } else {
      targetBudgets = await Budget.find({
        where: { user: { id: user.id } },
        relations: { category: true },
      });
    }
    Budget.convertListToTargetCurrency(targetBudgets, user);

    const totalTargetBudget = targetBudgets.reduce((sum, b) => sum + b.amount, 0);

    for (let i = 0; i < months; i++) {
      const targetDate = subMonths(today, i);
      const year = targetDate.getFullYear();
      const month = targetDate.getMonth() + 1;

      const { categoryStats } = await this.cashFlowService.calculateFlows(user, year, month);

      let actualSpent = 0;
      if (categoryId) {
        const stats = categoryStats.get(categoryId);
        if (stats) actualSpent = stats.outflow;
      } else {
        const budgetedCatIds = new Set(targetBudgets.map((b) => b.category?.id).filter(Boolean));
        for (const [catId, stats] of categoryStats.entries()) {
          if (budgetedCatIds.size > 0) {
            if (budgetedCatIds.has(catId)) actualSpent += stats.outflow;
          } else if (!stats.category.excludeFromCashFlow) {
            actualSpent += stats.outflow;
          }
        }
      }

      history.push(new MonthlyCategoryBudgetPerformance(year, month, totalTargetBudget, actualSpent));
    }

    history.sort((a, b) => {
      if (a.year !== b.year) return a.year - b.year;
      return a.month - b.month;
    });

    return new BudgetHistoryResponseDto(history);
  }
}
