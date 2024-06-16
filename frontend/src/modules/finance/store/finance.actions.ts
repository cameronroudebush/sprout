import { Transaction } from "@common";
import { createActionGroup, emptyProps, props } from "@ngrx/store";

export const FinanceActions = createActionGroup({
  source: "Finance",
  events: {
    AddTransactions: props<{ transactions: Transaction[] }>(),
    ClearTransactions: emptyProps(),
  },
});
