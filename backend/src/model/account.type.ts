/// This file contains types for each account so we can better identify what these belong to
export enum DepositoryAccountType {
  savings = "Savings",
  checking = "Checking",
  hysa = "HYSA",
}

export enum InvestmentAccountType {
  "401k" = "401K",
  brokerage = "Brokerage",
  ira = "IRA",
  hsa = "HSA",
}

export enum LoanAccountType {
  student = "Student",
  mortgage = "Mortgage",
  personal = "Personal",
  auto = "Auto",
}

export enum CreditAccountType {
  travel = "Travel",
  cashBack = "Cash Back",
}
