import { Account } from "@common";

export const ACCOUNT_NGRX_KEY = "account";

export interface AccountState {
  accounts: Account[];
}
