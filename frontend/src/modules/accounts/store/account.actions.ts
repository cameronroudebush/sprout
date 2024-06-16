import { Account } from "@common";
import { createActionGroup, emptyProps, props } from "@ngrx/store";

export const AccountActions = createActionGroup({
  source: "Account",
  events: {
    Add: props<{ data: Account[] }>(),
    Clear: emptyProps(),
  },
});
