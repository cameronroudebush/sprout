import { v4 as uuidv4 } from "uuid";

function getRandomNumber(min: number, max: number, decimals: number = 2): string {
  const str = (Math.random() * (max - min) + min).toFixed(decimals);
  return parseFloat(str).toString();
}

function getRandomInt(min: number, max: number): number {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function getRandomPastTimestamp(daysAgo: number = 365): number {
  const now = Date.now();
  const pastDate = new Date(now - Math.random() * daysAgo * 24 * 60 * 60 * 1000);
  return Math.floor(pastDate.getTime() / 1000);
}

/**
 * This class provides the ability to dynamically generate randomized balances for accounts. We will
 *  utilize the same accounts and institutions but the other values will be randomized.
 */
export class DevFinancialDataGenerator {
  /** A list of institutions we will process */
  private readonly institutions = [
    { name: "Chase Bank", url: "https://www.chase.com", id: "www.chase.com" },
    { name: "Fidelity Investments", url: "https://www.fidelity.com", id: "www.fidelity.com" },
    { name: "Vanguard Investments", url: "https://investor.vanguard.com/", id: "investor.vanguard.com" },
    { name: "Wells Fargo Bank", url: "https://www.wellsfargo.com", id: "www.wellsfargo.com" },
    { name: "Toyota Financial", url: "https://www.toyotafinancial.com", id: "www.toyotafinancial.com" },
    { name: "Discover Credit Card", url: "https://www.discover.com", id: "www.discover.com" },
  ];

  /** Account options */
  //prettier-ignore
  private readonly accounts = [
    { id: "ACT-ce52a842-0549-4931-9f31-ce16cbbc1d73", org: this.institutions[0]!, name: "Freedom Flex Card", currency: "USD", orgName: "Chase Bank", type: "credit" },
    { id: "ACT-458e7883-9d2d-45bc-9c33-0213d269c21e", org: this.institutions[0]!, name: "Home Loan", currency: "USD", orgName: "Chase Bank", type: "loan" },
    { id: "ACT-4816f1cb-54c5-47f8-a629-1561806b542b", org: this.institutions[1]!, name: "Investment Portfolio", currency: "USD", orgName: "Fidelity Investments", type: "investment" },
    { id: "ACT-985d764f-f984-49d0-8861-7ed0de9af966", org: this.institutions[1]!, name: "IRA Account", currency: "USD", orgName: "Vanguard Investments", type: "investment" },
    { id: "ACT-956a2bfe-fa44-495a-8310-343c5d478652", org: this.institutions[2]!, name: "Company 401k", currency: "USD", orgName: "Fidelity Investments", type: "investment" },
    { id: "ACT-4d3fab31-bc92-4307-a2d0-914a86046b31", org: this.institutions[1]!, name: "Health Savings Account", currency: "USD", orgName: "Vanguard Investments", type: "investment" },
    { id: "ACT-7d2e3f4a-5b6c-7d8e-9f0a-1b2c3d4e5f6a", org: this.institutions[3]!, name: "Checking Account", currency: "USD", orgName: "Wells Fargo Bank", type: "checking" },
    { id: "ACT-8e9f0a1b-2c3d-4e5f-6a7b-8c9d0e1f2a3b", org: this.institutions[3]!, name: "Savings Account", currency: "USD", orgName: "Wells Fargo Bank", type: "checking" },
    { id: "ACT-9f0a1b2c-3d4e-5f6a-7b8c-9d0e1f2a3b4c", org: this.institutions[2]!, name: "Investment Account", currency: "USD", orgName: "Wells Fargo Bank", type: "investment" },
    { id: "ACT-3e49c953-cab6-448a-9378-ac2f4d53f580", org: this.institutions[4]!, name: "Vehicle Loan", currency: "USD", orgName: "Toyota Financial", type: "loan" },
    { id: "ACT-e69b62d2-e929-41a9-bd70-2ef0204dfc0b", org: this.institutions[5]!, name: "Rewards Credit Card", currency: "USD", orgName: "Discover Credit Card", type: "credit" },
  ];

  /** Various transaction descriptions that we will populate */
  private readonly transactionDescriptions = {
    credit: ["Amazon.com", "Starbucks", "Grocery Store", "Restaurant Bill", "Online Subscription", "Gas Station", "Retail Store"],
    loan: ["Mortgage Payment", "Loan Payment", "Auto Loan Payment"],
    investment: ["Buy TSTR", "Dividend GLBE", "Buy Stock XYZ", "Sell DEF", "Investment Purchase", "Dividend Payment"],
    checking: ["Utilities Payment", "Payroll Deposit", "ATM Withdrawal", "Online Transfer", "Bill Payment", "Coffee Shop"],
    transfer: ["Credit Card Payment", "Transfer from Checking", "Transfer to Savings", "Bank Transfer"],
    retirement: ["IRA Contribution", "Employer Contribution", "401k Contribution"],
    healthcare: ["Pharmacy Purchase", "HSA Contribution", "Doctor Visit Co-pay"],
  };

  /** Various holdings that we may be able to use to mock additional data */
  private readonly holdingDescriptions = {
    "Fidelity Investments": [
      { description: "FAKE CRYPTO FUND", symbol: "TSTR" },
      { description: "FIDELITY GOVERNMENT MONEY MARKET (SPAXX)", symbol: "SPAXX" },
      { description: "GLOBAL EQUITY FUND", symbol: "GLBE" },
      { description: "LARGE CAP GROWTH ETF", symbol: "LCG" },
    ],
    "Vanguard Investments": [
      { description: "DIVERSIFIED INDEX FUND", symbol: "DIVX" },
      { description: "MID CAP GROWTH FUND", symbol: "MCGF" },
      { description: "FIDELITY GOVERNMENT MONEY MARKET (SPAXX)", symbol: "SPAXX" }, // Can be cross-institution for some types
      { description: "HIGH GROWTH EQUITIES", symbol: "HGHT" },
      { description: "TECH INNOVATORS INC.", symbol: "TINV" },
      { description: "HEALTHCARE GROWTH FUND", symbol: "HGRW" },
      { description: "FIDELITY GOVERNMENT CASH RESERVES (FDRXX)", symbol: "FDRXX" },
    ],
    "Wells Fargo Bank": [{ description: "GLOBAL GROWTH FUND", symbol: "GGF" }],
  };

  /**
   * Generates a random financial transaction.
   * @param accountType The type of account (e.g., 'credit', 'loan', 'investment').
   * @returns A randomly generated Transaction object.
   */
  private generateRandomTransaction(accountType: "checking" | "credit" | "loan" | "investment") {
    const isCreditOrLoan = accountType === "credit" || accountType === "loan";
    const amountSign = isCreditOrLoan ? "-" : Math.random() > 0.5 ? "-" : ""; // More likely to be negative for credit/loan
    let amount = getRandomNumber(1, isCreditOrLoan ? 500 : 2000, 2);
    if (isCreditOrLoan && Math.random() > 0.8) amountSign === "-" ? (amount = getRandomNumber(1, 1000, 2)) : (amount = getRandomNumber(1, 1000, 2));

    let descriptions = this.transactionDescriptions[accountType] || [];
    // Add common transaction types across account types
    descriptions = descriptions.concat(this.transactionDescriptions["transfer"] || []);
    if (accountType === "investment") descriptions = descriptions.concat(this.transactionDescriptions["retirement"] || []);
    if (accountType === "investment" || accountType === "checking") descriptions = descriptions.concat(this.transactionDescriptions["healthcare"] || []);

    const description = descriptions[getRandomInt(0, descriptions.length - 1)] || "Generic Transaction";
    let category: string | undefined;

    // Assign categories based on description, similar to the original data
    if (description.includes("Amazon.com") || description.includes("Retail Store")) category = "Online Shopping";
    else if (description.includes("Starbucks") || description.includes("Coffee Shop") || description.includes("Restaurant Bill")) category = "Food & Drink";
    else if (description.includes("Grocery Store")) category = "Groceries";
    else if (description.includes("Payment") || description.includes("Transfer")) category = "Payment";
    else if (description.includes("Mortgage") || description.includes("Loan Payment")) category = "Housing";
    else if (description.includes("Contribution") || description.includes("Retirement")) category = "Retirement";
    else if (description.includes("Invest")) category = "Investments";
    else if (description.includes("Utilities")) category = "Utilities";
    else if (description.includes("Payroll")) category = "Income";
    else if (description.includes("HSA") || description.includes("Pharmacy") || description.includes("Doctor")) category = "Healthcare";
    else if (description.includes("Subscription")) category = "Subscriptions";

    return {
      id: `TRN-${uuidv4().substring(0, 8)}`,
      posted: getRandomPastTimestamp(30), // Transactions within the last 30 days
      amount: `${amountSign}${amount}`,
      description: description,
      pending: Math.random() > 0.8, // 20% chance of being pending
      extra: category ? { category } : {},
    };
  }

  /**
   * Generates a random financial holding for a given organization.
   * @param orgName The name of the organization.
   * @returns A randomly generated Holding object.
   */
  private generateRandomHolding(orgName: string) {
    const availableHoldings = (this.holdingDescriptions as any)[orgName] || [];
    const chosenHolding = availableHoldings[getRandomInt(0, availableHoldings.length - 1)];

    const shares = parseFloat(getRandomNumber(0.1, 100, 2));
    const purchasePrice = parseFloat(getRandomNumber(1, 1000, 2));
    const costBasis = (shares * purchasePrice).toFixed(2);
    const marketValue = (shares * purchasePrice * (1 + (Math.random() * 0.2 - 0.1))).toFixed(2); // +/- 10% market value

    return {
      id: `HOL-${uuidv4()}`,
      created: getRandomPastTimestamp(730), // Created within the last 2 years
      currency: "USD",
      cost_basis: costBasis,
      description: chosenHolding ? chosenHolding.description : "Generic Holding",
      market_value: marketValue,
      purchase_price: purchasePrice.toFixed(2),
      shares: shares.toFixed(2),
      symbol: chosenHolding ? chosenHolding.symbol : "GEN",
    };
  }

  /** Generates a random balance based on the given account type */
  private generateRandomBalance(type: string) {
    switch (type) {
      case "credit":
        return getRandomNumber(-3000, -100, 2); // Negative balance for credit cards
      case "loan":
        return getRandomNumber(-200000, -180000, 2); // Large negative balance for loans
      case "investment":
        return getRandomNumber(100000, 150000, 2); // Positive balance for investments
      case "checking":
        return getRandomNumber(100, 10000, 2);
      default:
        return getRandomNumber(0, 10000, 2);
    }
  }

  /**
   * Generates a complete set of random financial data.
   * @param includeErrors Whether to include a random error message. Defaults to true.
   * @returns A FinancialData object with randomly generated account data.
   */
  public generateFinancialData(includeErrors: boolean = true) {
    const accounts = this.accounts.map((acc) => {
      // Generate random number of transactions
      const numTransactions = getRandomInt(1, 5);
      const transactions = [];
      for (let i = 0; i < numTransactions; i++) transactions.push(this.generateRandomTransaction(acc.type as any));
      // Generate random number of holdings
      const numHoldings = acc.type === "investment" ? getRandomInt(1, 5) : 0;
      const holdings = [];
      for (let i = 0; i < numHoldings; i++) holdings.push(this.generateRandomHolding(acc.org!.name));
      const balance = this.generateRandomBalance(acc.type).toString();

      return {
        ...acc,
        balance: balance.toString(),
        "available-balance": balance.toString(),
        "balance-date": new Date().getTime() / 1000,
        transactions,
        holdings,
      };
    });

    const errors: string[] = [];
    if (includeErrors && Math.random() > 0.7) {
      // 30% chance of an error
      const randomOrg = this.institutions[getRandomInt(0, this.institutions.length - 1)];
      errors.push(`Connection to ${randomOrg!.name} may need attention`);
    }

    return {
      errors: errors,
      accounts: accounts,
    };
  }
}
