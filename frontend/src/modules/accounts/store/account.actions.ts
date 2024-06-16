import { Account } from "@common";
import { createActionGroup, props } from "@ngrx/store";

export const AccountActions = createActionGroup({
  source: "Account",
  events: {
    Add: props<{ data: Account[] }>(),
  },
});
