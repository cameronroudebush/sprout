export enum AccountType {
  other = "other",
  depository = "depository",
  credit = "credit",
  asset = "asset",
  loan = "loan",
  investment = "investment",
  crypto = "crypto",
}

/** Account types included in cash flow calculations. */
export const CASH_FLOW_ACCOUNT_TYPES: readonly AccountType[] = [AccountType.depository, AccountType.credit];

/** Given an account type, returns if it's a liability (a debt) or not */
export function AccountTypeIsLiability(t: AccountType) {
  return [AccountType.loan, AccountType.credit].includes(t);
}
