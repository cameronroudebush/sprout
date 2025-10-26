/// This file contains types for each account so we can better identify what these belong to
export enum AccountSubType {
  // Depository
  savings = "Savings",
  checking = "Checking",
  hysa = "HYSA",
  // Investment
  "401k" = "401K",
  brokerage = "Brokerage",
  ira = "IRA",
  hsa = "HSA",
  // Loan
  student = "Student",
  mortgage = "Mortgage",
  personal = "Personal",
  auto = "Auto",
  // Credit
  travel = "Travel",
  cashBack = "Cash Back",
  // Crypto
  wallet = "Wallet",
  staking = "Staking",
}
