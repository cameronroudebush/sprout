import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType } from "@backend/account/model/account.type";
import { Category } from "@backend/category/model/category.model";
import { DatabaseBase } from "@backend/database/model/database.base";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { Logger } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";
import { eachDayOfInterval, subDays } from "date-fns";
import { startCase } from "lodash";
import { AppModule } from "../app.module";
import { SproutLogger } from "../core/logger";
import { DatabaseService } from "../database/database.service";

/**
 * A simple seeded pseudo-random number generator (PRNG) to produce consistent results.
 * This allows us to get the same sequence of "random" numbers on every run.
 */
function createSeededRandom(seed: number) {
  return function () {
    let t = (seed += 0x6d2b79f5);
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/** Centralized list of category names for easy reference and consistency. */
export const DEMO_CATEGORIES = {
  INCOME: {
    _name: "Income",
    PAYCHECK: "Paycheck",
  },
  EXPENSE: {
    _name: "Expense",
    HOME: {
      _name: "Home",
      MORTGAGE: "Mortgage",
      UTILITIES: "Utilities",
      MAINTENANCE: "Home Maintenance",
    },
    TRANSPORTATION: {
      _name: "Transportation",
      GAS: "Gas",
      CAR_PAYMENT: "Car Payment",
      CAR_MAINTENANCE: "Car Maintenance",
      PUBLIC_TRANSIT: "Public Transit",
    },
    FOOD: {
      _name: "Food",
      GROCERIES: "Groceries",
      RESTAURANTS: "Restaurants",
    },
    PERSONAL: {
      _name: "Personal",
      SHOPPING: "Shopping",
      HEALTHCARE: "Healthcare",
      SUBSCRIPTIONS: "Subscriptions",
      EDUCATION: "Education",
    },
    ENTERTAINMENT: "Entertainment",
    TRAVEL: "Travel",
  },
  SAVINGS_INVESTMENTS: {
    _name: "Savings & Investments",
    INVESTING: "Investing",
  },
};

/** This function/script is used to populate consistent demo data. */
export async function populateDemoData(daysToGenerate: number = 90) {
  // Check the numbers of days to generate
  if (isNaN(daysToGenerate) || daysToGenerate <= 0) throw new Error("Invalid number of days specified. Please provide a positive number.");
  // Create a "silent" app instance
  const app = await NestFactory.create(AppModule, {
    logger: new SproutLogger("demo"),
  });
  const logger = new Logger("demo");
  const database = app.get(DatabaseService);
  DatabaseBase.database = database;
  // Initialize the DB connection
  await database.source.initialize();
  if (await database.databaseExists()) throw new Error("Database already exists with data. Refusing to initialize demo data.");

  // DB doesn't exist so lets make sure the schema is populated
  await database.executeMigrations();

  /// Populate all of our data
  const user = await createUser();
  const accounts = await createAccounts(user);
  await createAccountHistory(accounts, daysToGenerate);
  await createTransactions(user, accounts, daysToGenerate);
  const holdings = await createHoldings(accounts);
  await createHoldingHistory(holdings, daysToGenerate);

  logger.log("Demo data population complete!");
  await app.close();
}

/** Creates the demo user to use to associate all info to */
async function createUser() {
  const logger = new Logger("demo:user");
  logger.log("Creating demo user.");
  let demoUser = await User.findOne({ where: { username: "demo" } });
  if (!demoUser) {
    await User.createUser({ username: "demo", password: "Demodemo", admin: true });
    demoUser = await User.findOne({ where: { username: "demo" } });
    logger.log("Created demo user and default categories.");
  } else {
    logger.log("Demo user already exists.");
  }
  return demoUser!;
}

/** Creates the institutions to associate accounts to */
async function createInstitution() {
  const logger = new Logger("demo:institution");
  const institutions = [
    Institution.fromPlain({ name: "Chase Bank", url: "https://www.chase.com", id: "www.chase.com", hasError: false }),
    Institution.fromPlain({ name: "Fidelity Investments", url: "https://www.fidelity.com", id: "www.fidelity.com", hasError: true }),
    Institution.fromPlain({ name: "Vanguard Investments", url: "https://investor.vanguard.com/", id: "investor.vanguard.com", hasError: false }),
    Institution.fromPlain({ name: "Wells Fargo Bank", url: "https://www.wellsfargo.com", id: "www.wellsfargo.com", hasError: false }),
    Institution.fromPlain({ name: "Toyota Financial", url: "https://www.toyotafinancial.com", id: "www.toyotafinancial.com", hasError: false }),
  ];
  logger.log(`Creating ${institutions.length} institutions.`);
  return await Institution.insertMany(institutions);
}

/** Creates necessary accounts */
async function createAccounts(demoUser: User) {
  const logger = new Logger("demo:account");
  const institutions = await createInstitution();
  const accounts = [
    // Depository
    new Account("Checking", "simple-fin", demoUser, institutions[0]!, 2500, 2400, AccountType.depository, "USD", AccountSubType.checking),
    new Account("Savings", "simple-fin", demoUser, institutions[0]!, 15000, 15000, AccountType.depository, "USD", AccountSubType.savings),
    new Account("High-Yield Savings", "simple-fin", demoUser, institutions[0]!, 50000, 50000, AccountType.depository, "USD", AccountSubType.hysa),
    // Credit
    new Account("Visa Credit Card", "simple-fin", demoUser, institutions[0]!, -500, 4500, AccountType.credit, "USD", AccountSubType.cashBack),
    // Loan
    new Account("Car Loan", "simple-fin", demoUser, institutions[4]!, -20000, 0, AccountType.loan, "USD", AccountSubType.personal),
    new Account("Mortgage", "simple-fin", demoUser, institutions[0]!, -250000, 0, AccountType.loan, "USD", AccountSubType.mortgage),
    // Investment
    new Account("Brokerage", "simple-fin", demoUser, institutions[1]!, 12000, 12000, AccountType.investment, "USD", AccountSubType.brokerage),
    new Account("401(k)", "simple-fin", demoUser, institutions[2]!, 275000, 75000, AccountType.investment, "USD", AccountSubType["401k"]),
    new Account("Roth IRA", "simple-fin", demoUser, institutions[2]!, 30000, 30000, AccountType.investment, "USD", AccountSubType.ira),
  ];
  logger.log(`Creating ${accounts.length} accounts.`);

  return await Account.insertMany(accounts);
}

/** Creates account history for the number of given days for the given accounts */
async function createAccountHistory(accounts: Account[], days: number): Promise<AccountHistory[]> {
  const logger = new Logger("demo:account:history");
  logger.log(`Creating account history for ${days} days.`);

  // Use a fixed seed for consistent "random" data.
  const seededRandom = createSeededRandom(12345);

  const endDate = new Date();
  const startDate = subDays(endDate, days - 1);
  const dateRange = eachDayOfInterval({ start: startDate, end: endDate });

  const allHistories: AccountHistory[] = [];

  for (const day of dateRange) {
    for (const account of accounts) {
      // Fluctuate balance slightly for history. We'll work backwards from the current balance.
      const daysFromEnd = Math.floor((endDate.getTime() - day.getTime()) / (1000 * 3600 * 24));
      const randomFactor = (seededRandom() - 0.5) * 0.01 * account.balance; // Fluctuate by up to 1% of balance
      const trend = (daysFromEnd / days) * 0.05 * account.balance; // Create a slight trend
      account.balance -= randomFactor + trend / days; // Adjust balance for the day
      allHistories.push(account.toAccountHistory(day));
    }
  }
  logger.log(`Inserting ${allHistories.length} account histories.`);
  await AccountHistory.insertMany(allHistories);
  return allHistories;
}

/** Creates transactions for the number of given days for the given accounts */
async function createTransactions(user: User, accounts: Account[], days: number) {
  const logger = new Logger("demo:transaction");
  logger.log(`Creating transactions for ${days} days.`);

  // Use a fixed seed for consistent "random" data.
  const seededRandom = createSeededRandom(54321); // Seed: 54321

  const endDate = new Date();
  const startDate = subDays(endDate, days - 1);
  const dateRange = eachDayOfInterval({ start: startDate, end: endDate });

  const categoryCache = new Map<string, Category>();
  const categoriesToCreate: Category[] = [];

  // Pre-populate the category cache with existing categories for the user
  const existingCategories = await Category.find({ where: { user: { id: user.id } } });
  for (const category of existingCategories) {
    categoryCache.set(category.name, category);
  }

  // Recursively create categories and sub-categories
  const createCategoriesRecursive = async (categoryObject: any, parent?: Category) => {
    for (const key in categoryObject) {
      if (key === "_name") continue;

      const value = categoryObject[key];
      let categoryName: string;
      let hasChildren = false;

      if (typeof value === "string") {
        categoryName = value;
      } else if (typeof value === "object" && value._name) {
        categoryName = value._name;
        hasChildren = true;
      } else {
        continue;
      }

      if (!categoryCache.has(categoryName)) {
        const newCategory = Category.fromPlain({ name: categoryName, user, parent });
        categoriesToCreate.push(newCategory);
        categoryCache.set(categoryName, newCategory);
      }

      if (hasChildren) {
        await createCategoriesRecursive(value, categoryCache.get(categoryName));
      }
    }
  };

  await createCategoriesRecursive(DEMO_CATEGORIES);

  // Pre-insert any new categories so they have IDs.
  if (categoriesToCreate.length > 0) {
    await Category.insertMany(categoriesToCreate);
    logger.log(`Inserted ${categoriesToCreate.length} new categories.`);
    // Re-populate cache with saved entities that now have IDs
    for (const newCategory of categoriesToCreate) {
      categoryCache.set(newCategory.name, newCategory);
    }
  }

  // Now that all categories exist, create sub-category relationships
  const subCategoryCreations: Promise<any>[] = [];
  const createSubCategoryLinks = (categoryObject: any, parentName?: string) => {
    const parentCategory = parentName ? categoryCache.get(parentName) : undefined;
    if (parentCategory) {
      for (const key in categoryObject) {
        if (key === "_name") continue;
        const value = categoryObject[key];
        const categoryName = typeof value === "string" ? value : value._name;
        const childCategory = categoryCache.get(categoryName)!;
        if (childCategory && !childCategory.parentCategory) {
          childCategory.parentCategory = parentCategory;
          subCategoryCreations.push(childCategory.update());
        }
        if (typeof value === "object") {
          createSubCategoryLinks(value, value._name);
        }
      }
    } else {
      // Top-level, recurse down
      Object.values(categoryObject)
        .filter((v: any) => typeof v === "object")
        .forEach((v: any) => createSubCategoryLinks(v, v._name));
    }
  };

  createSubCategoryLinks(DEMO_CATEGORIES);
  if (subCategoryCreations.length > 0) {
    await Promise.all(subCategoryCreations);
    logger.log(`Updated ${subCategoryCreations.length} categories with parent relationships.`);
    // Re-fetch categories to ensure parent relationships are loaded for getCategory()
    const allCategories = await Category.find({ where: { user: { id: user.id } }, relations: ["parentCategory"] });
    for (const newCategory of allCategories) {
      categoryCache.set(newCategory.name, newCategory);
    }
  }

  const getCategory = (name: string): Category => {
    const properName = startCase(name);
    if (!categoryCache.has(properName)) throw new Error(`Category "${properName}" not found in cache.`);
    return categoryCache.get(properName)!;
  };

  const allTransactions: Transaction[] = [];

  // Find a depository account to receive paychecks
  const checkingAccount = accounts.find((acc) => acc.subType === AccountSubType.checking);
  if (checkingAccount) {
    // Create bi-weekly paychecks
    for (let i = 0; i < days / 14; i++) {
      const paycheckDate = subDays(endDate, i * 14);
      const paycheckAmount = 3500 + (seededRandom() - 0.5) * 200; // $2500 +/- $100
      allTransactions.push(new Transaction(paycheckAmount, paycheckDate, "Paycheck", getCategory(DEMO_CATEGORIES.INCOME.PAYCHECK), false, checkingAccount));
    }
  }

  // Add some recurring monthly bills to the checking account
  if (checkingAccount) {
    const mortgagePayment = new Transaction(
      -1800,
      subDays(endDate, 15),
      "Mortgage Payment",
      getCategory(DEMO_CATEGORIES.EXPENSE.HOME.MORTGAGE),
      false,
      checkingAccount,
    );
    const carPayment = new Transaction(
      -450,
      subDays(endDate, 10),
      "Car Payment",
      getCategory(DEMO_CATEGORIES.EXPENSE.TRANSPORTATION.CAR_PAYMENT),
      false,
      checkingAccount,
    );
    const utilitiesPayment = new Transaction(
      -150,
      subDays(endDate, 20),
      "Utilities",
      getCategory(DEMO_CATEGORIES.EXPENSE.HOME.UTILITIES),
      false,
      checkingAccount,
    );
    const subscriptionsPayment = new Transaction(
      -45,
      subDays(endDate, 5),
      "Netflix, Spotify, etc.",
      getCategory(DEMO_CATEGORIES.EXPENSE.PERSONAL.SUBSCRIPTIONS),
      false,
      checkingAccount,
    );

    // Add for each month in the generated period
    for (let i = 0; i < Math.ceil(days / 30); i++) {
      const cloneTransaction = (t: Transaction, newDate: Date) => new Transaction(t.amount, newDate, t.description, t.category, t.pending, t.account);
      allTransactions.push(cloneTransaction(mortgagePayment, subDays(mortgagePayment.posted, i * 30)));
      allTransactions.push(cloneTransaction(carPayment, subDays(carPayment.posted, i * 30)));
      allTransactions.push(cloneTransaction(utilitiesPayment, subDays(utilitiesPayment.posted, i * 30)));
      allTransactions.push(cloneTransaction(subscriptionsPayment, subDays(subscriptionsPayment.posted, i * 30)));
    }
  }

  for (const day of dateRange) {
    for (const account of accounts) {
      // Only generate random daily expenses for depository and credit accounts
      if (account.type === AccountType.depository || account.type === AccountType.credit) {
        // Randomly decide how many transactions to create for this account on this day (0 to 2)
        const numTransactions = Math.floor(seededRandom() * 3);

        for (let i = 0; i < numTransactions; i++) {
          let amount = 0;
          let description = "Random Transaction";
          let category: Category | undefined;

          if (account.type === AccountType.depository) {
            amount = -(seededRandom() * 100 + 5); // Expense
            const expenseType = [
              DEMO_CATEGORIES.EXPENSE.FOOD.GROCERIES,
              DEMO_CATEGORIES.EXPENSE.FOOD.RESTAURANTS,
              DEMO_CATEGORIES.EXPENSE.PERSONAL.SHOPPING,
              DEMO_CATEGORIES.EXPENSE.TRANSPORTATION.GAS,
              DEMO_CATEGORIES.EXPENSE.ENTERTAINMENT,
              DEMO_CATEGORIES.EXPENSE.HOME.UTILITIES,
              DEMO_CATEGORIES.EXPENSE.PERSONAL.HEALTHCARE,
            ][Math.floor(seededRandom() * 7)];
            description = `${expenseType} Purchase`;
            category = getCategory(expenseType!);
          } else if (account.type === AccountType.credit) {
            amount = -(seededRandom() * 75 + 10);
            description = "Credit Card Purchase";
            category = getCategory(DEMO_CATEGORIES.EXPENSE.PERSONAL.SHOPPING);
          }

          if (amount !== 0) {
            allTransactions.push(new Transaction(amount, day, description, category, seededRandom() > 0.8, account));
          }
        }
      } else if (account.type === AccountType.investment) {
        // For investment accounts, only create occasional large contributions
        if (seededRandom() > 0.95) {
          const category = getCategory(DEMO_CATEGORIES.SAVINGS_INVESTMENTS.INVESTING);
          allTransactions.push(new Transaction(-500, day, "Investment Contribution", category, false, account));
        }
      }
    }
  }

  logger.log(`Inserting ${allTransactions.length} transactions.`);
  await Transaction.insertMany(allTransactions);
  return allTransactions;
}

/** Creates holdings for investment accounts picked from the given accounts */
async function createHoldings(accounts: Account[]): Promise<Holding[]> {
  const logger = new Logger("demo:holding");
  logger.log(`Creating holdings for investment accounts.`);

  // Use a fixed seed for consistent "random" data.
  const seededRandom = createSeededRandom(67890);

  const investmentAccounts = accounts.filter((acc) => acc.type === AccountType.investment);
  const allHoldings: Holding[] = [];

  const holdingTemplates = [
    { symbol: "VTSAX", description: "Vanguard Total Stock Market Index Fund" },
    { symbol: "SPY", description: "SPDR S&P 500 ETF Trust" },
    { symbol: "AAPL", description: "Apple Inc." },
    { symbol: "MSFT", description: "Microsoft Corporation" },
    { symbol: "AMZN", description: "Amazon.com, Inc." },
    { symbol: "GOOGL", description: "Alphabet Inc. Class A" },
  ];

  for (const account of investmentAccounts) {
    // Create 1 to 3 holdings per investment account
    const numHoldings = Math.floor(seededRandom() * 3) + 1;
    let remainingBalance = account.balance;

    for (let i = 0; i < numHoldings; i++) {
      const template = holdingTemplates[Math.floor(seededRandom() * holdingTemplates.length)]!;
      const isLastHolding = i === numHoldings - 1;

      // Assign a portion of the account's balance to this holding
      const marketValue = isLastHolding ? remainingBalance : remainingBalance * seededRandom() * 0.7;
      remainingBalance -= marketValue;

      const costBasis = marketValue * (1 - (seededRandom() - 0.5) * 0.2); // Cost basis within +/- 10% of market value
      const shares = seededRandom() * 100 + 1;
      const purchasePrice = costBasis / shares;

      const newHolding = Holding.fromPlain({
        account,
        costBasis,
        marketValue,
        description: template.description,
        purchasePrice,
        shares,
        symbol: template.symbol,
        currency: account.currency,
      });
      allHoldings.push(newHolding);
    }
  }

  logger.log(`Inserting ${allHoldings.length} holdings.`);
  return await Holding.insertMany(allHoldings);
}

/** Creates holdings for investment accounts picked from the given accounts */
async function createHoldingHistory(holdings: Holding[], days: number): Promise<HoldingHistory[]> {
  const logger = new Logger("demo:holding:history");
  logger.log(`Creating holding history for ${days} days.`);

  // Use a fixed seed for consistent "random" data.
  const seededRandom = createSeededRandom(13579);

  const endDate = new Date();
  const startDate = subDays(endDate, days - 1);
  const dateRange = eachDayOfInterval({ start: startDate, end: endDate });

  const allHoldingHistories: HoldingHistory[] = [];

  for (const day of dateRange) {
    for (const holding of holdings) {
      // Fluctuate market value slightly for history. We'll work backwards from the current value.
      const daysFromEnd = Math.floor((endDate.getTime() - day.getTime()) / (1000 * 3600 * 24));
      const randomFactor = (seededRandom() - 0.5) * 0.02 * holding.marketValue; // Fluctuate by up to 2%
      const trend = (daysFromEnd / days) * 0.08 * holding.marketValue; // Create a slight upward trend
      holding.marketValue -= randomFactor + trend / days; // Adjust market value for the day

      const newHoldingHistory = HoldingHistory.fromPlain({
        holding: holding,
        time: day,
        marketValue: holding.marketValue,
        costBasis: holding.costBasis,
        purchasePrice: holding.purchasePrice,
        shares: holding.shares,
      });
      allHoldingHistories.push(newHoldingHistory);
    }
  }

  logger.log(`Inserting ${allHoldingHistories.length} holding history records.`);
  await HoldingHistory.insertMany(allHoldingHistories);
  return allHoldingHistories;
}
