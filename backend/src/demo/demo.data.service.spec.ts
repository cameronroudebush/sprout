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
import { DemoDataService } from "@backend/demo/demo.data.service.js";
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
    vi.clearAllMocks();

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
        .mockResolvedValueOnce(null) // first check
        .mockResolvedValueOnce(TestEntities.user); // check after User.createUser

      vi.spyOn(User, "createUser").mockResolvedValue({} as any);

      const userConfig = TestEntities.userConfig;
      userConfig.update = vi.fn().mockResolvedValue(userConfig);
      vi.spyOn(UserConfig, "findOne").mockResolvedValue(userConfig);

      await service.populateDemoData(30);
      expect(User.createUser).toHaveBeenCalled();

      Configuration.isDemoMode = originalIsDemo;
    });
  });
});
