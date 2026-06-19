import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType } from "@backend/account/model/account.type";
import { Category } from "@backend/category/model/category.model";
import { ChatHistory } from "@backend/chat/model/chat.history.model";
import { Configuration } from "@backend/config/core";
import { DatabaseService } from "@backend/database/database.service";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { ProviderType } from "@backend/providers/base/provider.type";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRule } from "@backend/transaction/model/transaction.rule.model";
import { TransactionRuleType } from "@backend/transaction/model/transaction.rule.type";
import { ChartRange } from "@backend/user/model/chart.range.model";
import { UserConfig } from "@backend/user/model/user.config.model";
import { User } from "@backend/user/model/user.model";
import { Injectable, Logger } from "@nestjs/common";
import { eachDayOfInterval, subDays } from "date-fns";
import { startCase } from "lodash";

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

@Injectable()
export class DemoDataService {
  private readonly logger = new Logger("demo:service");

  /** Default credentials we'll use for authenticating this user */
  public static readonly credentials = {
    username: "demo",
    password: "Demodemo",
  };

  constructor(private readonly database: DatabaseService) {}

  /** This function/script is used to populate consistent demo data. */
  async populateDemoData(daysToGenerate: number = 150) {
    // Safety check for production environments
    if (!Configuration.isDemoMode) throw new Error("Cannot run demo data population unless application is explicitly in Demo Mode.");

    // Check the numbers of days to generate
    if (isNaN(daysToGenerate) || daysToGenerate <= 0) throw new Error("Invalid number of days specified. Please provide a positive number.");

    this.logger.warn("Wiping database and re-executing migrations for clean slate.");
    await this.database.source.dropDatabase();
    await this.database.executeMigrations();

    this.logger.log("Starting to populate demo data....");
    /// Populate all of our data
    const user = await this.createUser();
    const accounts = await this.createAccounts(user);
    await this.createAccountHistory(accounts, daysToGenerate);
    await this.createTransactions(user, accounts, daysToGenerate);
    await this.populateTransactionRules(user);
    const holdings = await this.createHoldings(accounts);
    await this.createHoldingHistory(holdings, daysToGenerate);
    await this.populateChat(user);

    this.logger.log("Demo data population complete!");
  }

  /** Creates the demo user to use to associate all info to */
  private async createUser() {
    const logger = new Logger("demo:user");
    logger.log("Creating demo user.");
    let demoUser = await User.findOne({ where: { username: "demo" } });
    if (!demoUser) {
      await User.createUser({ username: DemoDataService.credentials.username, password: DemoDataService.credentials.password, admin: true });
      // Update the user config
      const userConfig = (await UserConfig.findOne({ where: { user: { username: "demo" } } }))!;
      userConfig.netWorthRange = ChartRange.sevenDays;
      await userConfig.update();
      demoUser = await User.findOne({ where: { username: "demo" } });
      logger.log("Created demo user and default categories.");
    } else {
      logger.log("Demo user already exists.");
    }
    return demoUser!;
  }

  /** Creates the institutions to associate accounts to */
  private async createInstitution(user: User) {
    const logger = new Logger("demo:institution");
    const institutions = [
      Institution.fromPlain({ name: "Chase Bank", url: "https://www.chase.com", id: "www.chase.com", hasError: false }),
      Institution.fromPlain({ name: "Fidelity Investments", url: "https://www.fidelity.com", id: "www.fidelity.com", hasError: true }),
      Institution.fromPlain({ name: "Vanguard Investments", url: "https://investor.vanguard.com/", id: "investor.vanguard.com", hasError: false }),
      Institution.fromPlain({ name: "Wells Fargo Bank", url: "https://www.wellsfargo.com", id: "www.wellsfargo.com", hasError: false }),
      Institution.fromPlain({ name: "Toyota Financial", url: "https://www.toyotafinancial.com", id: "www.toyotafinancial.com", hasError: false }),
    ];
    logger.log(`Creating ${institutions.length} institutions.`);
    institutions.forEach((x) => (x.user = user));
    return await Institution.insertMany(institutions);
  }

  /** Creates necessary accounts */
  private async createAccounts(demoUser: User) {
    const logger = new Logger("demo:account");
    const institutions = await this.createInstitution(demoUser);
    const accounts = [
      // Depository
      new Account("Checking", ProviderType.simpleFin, demoUser, institutions[0]!, 2500, 2400, AccountType.depository, "USD", AccountSubType.checking),
      new Account("Savings", ProviderType.simpleFin, demoUser, institutions[0]!, 15000, 15000, AccountType.depository, "USD", AccountSubType.savings),
      new Account("High-Yield Savings", ProviderType.simpleFin, demoUser, institutions[0]!, 50000, 50000, AccountType.depository, "USD", AccountSubType.hysa),
      // Credit
      new Account("Visa Credit Card", ProviderType.simpleFin, demoUser, institutions[0]!, -500, 4500, AccountType.credit, "USD", AccountSubType.cashBack),
      // Loan
      new Account("Car Loan", ProviderType.simpleFin, demoUser, institutions[4]!, -20000, 0, AccountType.loan, "USD", AccountSubType.personal),
      new Account("Mortgage", ProviderType.simpleFin, demoUser, institutions[0]!, -250000, 0, AccountType.loan, "USD", AccountSubType.mortgage),
      // Investment
      new Account("Brokerage", ProviderType.simpleFin, demoUser, institutions[1]!, 12000, 12000, AccountType.investment, "USD", AccountSubType.brokerage),
      new Account("401(k)", ProviderType.simpleFin, demoUser, institutions[2]!, 275000, 75000, AccountType.investment, "USD", AccountSubType["401k"]),
      new Account("Roth IRA", ProviderType.simpleFin, demoUser, institutions[2]!, 30000, 30000, AccountType.investment, "USD", AccountSubType.ira),
      // Crypto
      new Account("Bitcoin", ProviderType.simpleFin, demoUser, institutions[2]!, 1534, 1534, AccountType.crypto, "USD", AccountSubType.wallet),
    ];
    logger.log(`Creating ${accounts.length} accounts.`);

    return await Account.insertMany(accounts);
  }

  /** Creates account history for the number of given days for the given accounts */
  private async createAccountHistory(accounts: Account[], days: number): Promise<AccountHistory[]> {
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
  private async createTransactions(user: User, accounts: Account[], days: number) {
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
      const allCategories = await Category.find({ where: { user: { id: user.id } }, relations: { parentCategory: true } });
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
  private async createHoldings(accounts: Account[]): Promise<Holding[]> {
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

  /** Populates some sample transaction rules */
  private async populateTransactionRules(user: User) {
    const logger = new Logger("demo:transaction:rules");
    logger.log(`Inserting sample transaction rules.`);
    const categories = await Category.find({ where: { user: { id: user.id } } });
    const findCat = (name: string) => categories.find((x) => x.name === name);
    await TransactionRule.insertMany([
      new TransactionRule(user, TransactionRuleType.description, "mcdonalds", findCat("Restaurants")),
      new TransactionRule(user, TransactionRuleType.description, "shell", findCat("Gas")),
      new TransactionRule(user, TransactionRuleType.description, "chevron", findCat("Gas")),
      new TransactionRule(user, TransactionRuleType.description, "netflix", findCat("Subscriptions")),
      new TransactionRule(user, TransactionRuleType.description, "spotify", findCat("Subscriptions")),
      new TransactionRule(user, TransactionRuleType.description, "amazon", findCat("Shopping")),
      new TransactionRule(user, TransactionRuleType.description, "whole foods", findCat("Groceries")),
      new TransactionRule(user, TransactionRuleType.description, "uber", findCat("Public Transit")),
    ]);
  }

  /** Populates some sample chat data */
  private async populateChat(user: User) {
    const logger = new Logger("demo:chat");
    logger.log(`Inserting sample AI chat messages.`);
    let timeline = new Date().getTime() - 10 * 60 * 1000;

    const stepTime = (seconds: number) => {
      timeline += seconds * 1000;
      return new Date(timeline);
    };

    const chats = [
      new ChatHistory(user, "How much did I spend on food last month?", "user", stepTime(0), false),
      new ChatHistory(
        user,
        "Based on your transaction history, you spent a total of $642.50 on food last month, which is about 12% of your total expenses.",
        "model",
        stepTime(5),
        false,
      ),
      new ChatHistory(user, "Give me the top 2 suggestions to further improve my net worth.", "user", stepTime(60), false),
      new ChatHistory(
        user,
        `1. Use $20,000 from High-Yield Savings to pay off the personal loan (Car Loan) to eliminate interest expenses and reduce total liabilities.
         2. Reduce discretionary spending in "Shopping" and "Entertainment" by $200/month, redirecting those funds into your Brokerage account to maximize compound growth.
         Consult a financial advisor before making decisions.`,
        "model",
        stepTime(5),
        false,
      ),
      new ChatHistory(user, "What is my largest recurring monthly expense?", "user", stepTime(60), false),
      new ChatHistory(user, "Your largest recurring expense is your Mortgage payment at $1,800 per month.", "model", stepTime(5), false),
      new ChatHistory(user, "Did my subscription fees go up this month?", "user", stepTime(60), false),
      new ChatHistory(
        user,
        "Yes, your streaming service bundle increased from $14.99 to $18.99 on the 15th. You also had a yearly domain renewal of $12.00 hit your credit card last Tuesday.",
        "model",
        stepTime(5),
        false,
      ),
      new ChatHistory(user, "How much do I have left in my entertainment budget for this week?", "user", stepTime(60), false),
      new ChatHistory(
        user,
        "You have $45.20 remaining of your weekly $150.00 entertainment allowance. You've spent $104.80 so far, primarily at 'Cinemark Theatres' and 'The Daily Grind Coffee'.",
        "model",
        stepTime(5),
        false,
      ),
      new ChatHistory(user, "Can I afford to buy a $300 bike right now?", "user", stepTime(60), false),
      new ChatHistory(
        user,
        "Your checking account has $1,200, and your upcoming essential bills before your next paycheck total $650. You can comfortably afford the bike using your unallocated cash reserve without dipping into savings.",
        "model",
        stepTime(5),
        false,
      ),
    ];

    for (const chat of chats) await chat.insert();
  }

  /** Creates holdings for investment accounts picked from the given accounts */
  private async createHoldingHistory(holdings: Holding[], days: number): Promise<HoldingHistory[]> {
    const logger = new Logger("demo:holding:history");
    logger.log(`Creating holding history for ${days} days.`);

    const seededRandom = createSeededRandom(13579);
    const endDate = new Date();
    const startDate = subDays(endDate, days - 1);
    const dateRange = eachDayOfInterval({ start: startDate, end: endDate });
    const allHoldingHistories: HoldingHistory[] = [];

    for (const day of dateRange) {
      for (const holding of holdings) {
        const daysFromEnd = Math.floor((endDate.getTime() - day.getTime()) / (1000 * 3600 * 24));
        const randomFactor = (seededRandom() - 0.5) * 0.02 * holding.marketValue;
        const trend = (daysFromEnd / days) * 0.08 * holding.marketValue;
        holding.marketValue -= randomFactor + trend / days;

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
}
