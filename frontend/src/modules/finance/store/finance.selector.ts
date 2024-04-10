import { createFeatureSelector } from "@ngrx/store";
import { FINANCE_NGRX_KEY, FinanceState } from "./finance.state";

export const selectFinanceState = createFeatureSelector<FinanceState>(FINANCE_NGRX_KEY);
