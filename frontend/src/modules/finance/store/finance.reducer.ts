import { createReducer, on } from "@ngrx/store";
import { FinanceActions } from "./finance.actions";
import { FinanceState } from "./finance.state";

export const financeReducer = createReducer(
  { transactions: [] } as FinanceState,
  on(FinanceActions.addTransactions, (state, { transactions }) => {
    return { ...state, transactions: state.transactions.concat(transactions) };
  }),
  on(FinanceActions.clearTransactions, (state) => {
    return { ...state, transactions: [] };
  }),
);
