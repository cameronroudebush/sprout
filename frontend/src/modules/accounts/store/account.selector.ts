import { createFeatureSelector } from "@ngrx/store";
import { ACCOUNT_NGRX_KEY, AccountState } from "./account.state";

export const selectAccountState = createFeatureSelector<AccountState>(ACCOUNT_NGRX_KEY);
