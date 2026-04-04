export enum AccountType {
  other = "other",
  depository = "depository",
  credit = "credit",
  asset = "asset",
  loan = "loan",
  investment = "investment",
  crypto = "crypto",
}

/** Given an account type, returns if it's a liability (a debt) or not */
export function AccountTypeIsLiability(t: AccountType) {
  return [AccountType.loan, AccountType.credit].includes(t);
}
