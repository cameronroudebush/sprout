import { Transaction } from "@common";
import { createActionGroup, props } from "@ngrx/store";

export const FinanceActions = createActionGroup({
  source: "Finance",
  events: {
    AddTransactions: props<{ transactions: Transaction[] }>(),
  },
});
