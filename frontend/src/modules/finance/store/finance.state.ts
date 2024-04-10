import { Transaction } from "@common";

export const FINANCE_NGRX_KEY = "finance";

export interface FinanceState {
  transactions: Transaction[];
}
