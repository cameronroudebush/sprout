import { createReducer, on } from "@ngrx/store";
import { AccountActions } from "./account.actions";
import { AccountState } from "./account.state";

export const accountReducer = createReducer(
  { accounts: [] } as AccountState,
  on(AccountActions.add, (state, { data }) => {
    return { ...state, accounts: state.accounts.concat(data) };
  }),
);
