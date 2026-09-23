import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { AccountHistory } from "@backend/account/model/account.history.model.js";
import { Account } from "@backend/account/model/account.model.js";
import { AccountSubType } from "@backend/account/model/account.sub.type.js";
import { AccountType } from "@backend/account/model/account.type.js";
import { Category } from "@backend/category/model/category.model.js";
import { ChatHistory } from "@backend/chat/model/chat.history.model.js";
import { ChatOverview } from "@backend/chat/model/chat.overview.model.js";
import { Configuration } from "@backend/config/core.js";
import { DatabaseService } from "@backend/database/database.service.js";
import { DemoDataService, DEMO_CATEGORIES } from "@backend/demo/demo.data.service.js";
import { HoldingHistory } from "@backend/holding/model/holding.history.model.js";
import { Holding } from "@backend/holding/model/holding.model.js";
import { Institution } from "@backend/institution/model/institution.model.js";
import { TestEntities } from "@backend/test/entities.js";
import { Transaction } from "@backend/transaction/model/transaction.model.js";
import { TransactionRule } from "@backend/transaction/model/transaction.rule.model.js";
import { UserConfig } from "@backend/user/model/user.config.model.js";
import { User } from "@backend/user/model/user.model.js";

describe("DemoDataService", () => {
  let service: DemoDataService;
  let databaseService: Mocked<DatabaseService>;

  beforeEach(() => {
    vi.restoreAllMocks();

    databaseService = {
      source: {
        dropDatabase: vi.fn().mockResolvedValue(undefined),
      },
      executeMigrations: vi.fn().mockResolvedValue(undefined),
    } as unknown as Mocked<DatabaseService>;

    service = new DemoDataService(databaseService);
  });

  describe("populateDemoData", () => {
    it("should throw error if application is not in demo mode", async () => {
      const originalIsDemo = Configuration.isDemoMode;
      Configuration.isDemoMode = false;

      await expect(service.populateDemoData(10)).rejects.toThrow("Cannot run demo data population unless application is explicitly in Demo Mode.");

      Configuration.isDemoMode = originalIsDemo;
    });

    it("should throw error if daysToGenerate is invalid", async () => {
      const originalIsDemo = Configuration.isDemoMode;
      Configuration.isDemoMode = true;

      await expect(service.populateDemoData(0)).rejects.toThrow("Invalid number of days specified.");

      Configuration.isDemoMode = originalIsDemo;
    });

    it("should execute clean database setup and populate demo data when user exists or is new", async () => {
      const originalIsDemo = Configuration.isDemoMode;
      Configuration.isDemoMode = true;

      // 1. First run when User already exists
      vi.spyOn(User, "findOne").mockResolvedValue(TestEntities.user);
      vi.spyOn(Institution, "insertMany").mockImplementation(async (insts: any) => insts);

      const mockAccounts = [
        Account.fromPlain({ id: "acc-1", name: "Checking", balance: 2500, subType: AccountSubType.checking, type: AccountType.depository }),
        Account.fromPlain({ id: "acc-2", name: "Credit", balance: -500, subType: AccountSubType.cashBack, type: AccountType.credit }),
        Account.fromPlain({ id: "acc-3", name: "Brokerage", balance: 10000, subType: AccountSubType.brokerage, type: AccountType.investment }),
      ];
      vi.spyOn(Account, "insertMany").mockResolvedValue(mockAccounts as any);

      vi.spyOn(AccountHistory, "insertMany").mockImplementation(async (histories: any) => {
        histories.forEach((h: any, idx: number) => {
          h.account = h.account || mockAccounts[idx % mockAccounts.length];
        });
        return histories;
      });

      vi.spyOn(Category.prototype, "update").mockImplementation(async function (this: any) {
        this.id = this.id || "cat-mock-id";
        return this;
      });

      const parentCat = Category.fromPlain({ id: "p1", name: "Home", user: TestEntities.user });
      const childCat = Category.fromPlain({ id: "c1", name: "Mortgage", user: TestEntities.user });
      vi.spyOn(Category, "find").mockResolvedValue([parentCat, childCat]);
      vi.spyOn(Category, "insertMany").mockImplementation(async (cats: any) => cats);
      vi.spyOn(Transaction, "insertMany").mockResolvedValue([]);
      vi.spyOn(TransactionRule, "insertMany").mockResolvedValue([]);
      vi.spyOn(Holding, "insertMany").mockResolvedValue([TestEntities.holding] as any);
      vi.spyOn(HoldingHistory, "insertMany").mockResolvedValue([]);
      vi.spyOn(ChatHistory.prototype, "insert").mockResolvedValue({} as any);
      vi.spyOn(ChatOverview, "insertMany").mockResolvedValue([]);

      await service.populateDemoData(30);

      expect(databaseService.source.dropDatabase).toHaveBeenCalled();
      expect(databaseService.executeMigrations).toHaveBeenCalled();

      // 2. Second run when user is new and created
      vi.spyOn(User, "findOne")
        .mockResolvedValueOnce(null) // first findOne in createUser returns null
        .mockResolvedValueOnce(TestEntities.user); // second findOne returns demoUser

      vi.spyOn(User, "createUser").mockResolvedValue(TestEntities.user);
      const mockUserConfig = { netWorthRange: undefined, update: vi.fn().mockResolvedValue(true) };
      vi.spyOn(UserConfig, "findOne").mockResolvedValue(mockUserConfig as any);

      await service.populateDemoData(30);

      expect(User.createUser).toHaveBeenCalled();
      expect(mockUserConfig.update).toHaveBeenCalled();

      Configuration.isDemoMode = originalIsDemo;
    });
  });

  describe("transaction generation edge cases", () => {
    const buildCategoryTree = (categoryObject: Record<string, any>, parent?: Category): Category[] => {
      const result: Category[] = [];
      for (const key in categoryObject) {
        if (key === "_name") continue;
        const value = categoryObject[key];
        const name: string = typeof value === "string" ? value : value._name;
        const category = Category.fromPlain({ id: name, name, user: TestEntities.user });
        if (parent) category.parentCategory = parent;
        result.push(category);
        if (value && typeof value === "object" && value._name) result.push(...buildCategoryTree(value, category));
      }
      return result;
    };

    const buildAccount = (overrides: Record<string, any>) =>
      Account.fromPlain({
        id: "acc-edge",
        name: "Edge Account",
        balance: 1000,
        subType: AccountSubType.checking,
        type: AccountType.depository,
        currency: "USD",
        user: TestEntities.user,
        ...overrides,
      });

    beforeEach(() => {
      vi.spyOn(Category, "find").mockResolvedValue([]);
      vi.spyOn(Category, "insertMany").mockImplementation(async (categories: any) => categories);
      vi.spyOn(Category.prototype, "update").mockImplementation(async function (this: Category) {
        return this;
      });
      vi.spyOn(Transaction, "insertMany").mockResolvedValue([]);
    });

    it("should skip category creation when every demo category already exists", async () => {
      vi.spyOn(Category, "find").mockResolvedValue(buildCategoryTree(DEMO_CATEGORIES));

      await (service as any).createTransactions(TestEntities.user, [buildAccount({})], 5);

      expect(Category.insertMany).not.toHaveBeenCalled();
      expect(Transaction.insertMany).toHaveBeenCalled();
    });

    it("should skip category entries that are neither strings nor named groups", async () => {
      (DEMO_CATEGORIES.EXPENSE as any).UNLABELED = { unexpected: true };
      try {
        await (service as any).createTransactions(TestEntities.user, [buildAccount({})], 5);
        expect(Transaction.insertMany).toHaveBeenCalled();
      } finally {
        delete (DEMO_CATEGORIES.EXPENSE as any).UNLABELED;
      }
    });

    it("should generate demo transactions without a checking account", async () => {
      const accounts = [
        buildAccount({ id: "savings-edge", subType: AccountSubType.savings }),
        buildAccount({ id: "loan-edge", type: AccountType.loan, subType: AccountSubType.personal, balance: -1000 }),
        buildAccount({ id: "crypto-edge", type: AccountType.crypto, subType: AccountSubType.wallet, balance: 200 }),
      ];

      await (service as any).createTransactions(TestEntities.user, accounts, 30);

      expect(Transaction.insertMany).toHaveBeenCalled();
    });

    it("should throw when a referenced category is missing from the cache", async () => {
      const original = DEMO_CATEGORIES.INCOME.PAYCHECK;
      DEMO_CATEGORIES.INCOME.PAYCHECK = "weird-paycheck";
      try {
        await expect((service as any).createTransactions(TestEntities.user, [buildAccount({})], 14)).rejects.toThrow(
          'Category "Weird Paycheck" not found in cache.',
        );
      } finally {
        DEMO_CATEGORIES.INCOME.PAYCHECK = original;
      }
    });
  });

  describe("populateChatOverviews fallbacks", () => {
    it("should compute overviews without investment accounts or history", async () => {
      vi.spyOn(ChatOverview, "insertMany").mockResolvedValue([]);

      const accounts = [
        Account.fromPlain({ id: "dep-edge", name: "Savings", balance: 0, subType: AccountSubType.savings, type: AccountType.depository }),
        Account.fromPlain({ id: "loan-edge", name: "Loan", balance: -500, subType: AccountSubType.personal, type: AccountType.loan }),
        Account.fromPlain({ id: "crypto-edge", name: "Crypto", balance: 300, subType: AccountSubType.wallet, type: AccountType.crypto }),
      ];

      await (service as any).populateChatOverviews(TestEntities.user, accounts, []);

      expect(ChatOverview.insertMany).toHaveBeenCalled();
    });
  });
});
