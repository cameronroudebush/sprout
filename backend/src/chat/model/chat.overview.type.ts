/** The type of chat overview types we support */
export enum ChatOverviewType {
  /** An overarching overview of all accounts for the user */
  accounts = "accounts",
  holdings = "holdings",
  /** An overview of a users specific month of budgeting */
  budgets = "budgets",
}

export interface ChatOverviewPeriod {
  year: number;
  month: number;
}

export function isFutureChatOverviewPeriod(period: ChatOverviewPeriod, now = new Date()): boolean {
  return period.year > now.getFullYear() || (period.year === now.getFullYear() && period.month > now.getMonth() + 1);
}

export function resolveChatOverviewPeriod(type: ChatOverviewType, period?: ChatOverviewPeriod, now = new Date()): ChatOverviewPeriod | undefined {
  if (type !== ChatOverviewType.budgets) return undefined;
  return period ?? { year: now.getFullYear(), month: now.getMonth() + 1 };
}
