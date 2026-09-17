import { setupTests } from "@backend/test/helpers";
setupTests();

import { DemoDataService } from "@backend/demo/demo.data.service";
import { Configuration } from "@backend/config/core";
import { DatabaseService } from "@backend/database/database.service";
import { User } from "@backend/user/model/user.model";
import { Account } from "@backend/account/model/account.model";
import { AccountHistory } from "@backend/account/model/account.history.model";
import { Category } from "@backend/category/model/category.model";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRule } from "@backend/transaction/model/transaction.rule.model";
import { Holding } from "@backend/holding/model/holding.model";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { ChatHistory } from "@backend/chat/model/chat.history.model";
import { ChatOverview } from "@backend/chat/model/chat.overview.model";
import { TestEntities } from "@backend/test/entities";
import { AccountType } from "@backend/account/model/account.type";
import { AccountSubType } from "@backend/account/model/account.sub.type";

describe("DemoDataService", () => {
  let service: DemoDataService;
  let databaseService: jest.Mocked<DatabaseService>;

  beforeEach(() => {
    jest.clearAllMocks();

    databaseService = {
      source: {
        dropDatabase: jest.fn().mockResolvedValue(undefined),
      },
      executeMigrations: jest.fn().mockResolvedValue(undefined),
    } as any;

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

    it("should execute clean database setup and populate demo data if demo mode is enabled", async () => {
      const originalIsDemo = Configuration.isDemoMode;
      Configuration.isDemoMode = true;

      jest.spyOn(User, "findOne").mockResolvedValue(TestEntities.user);
      jest.spyOn(User, "createUser").mockResolvedValue({} as any);
      const mockAccounts = [
        Account.fromPlain({ id: "acc-1", subType: AccountSubType.checking, type: AccountType.depository }),
        Account.fromPlain({ id: "acc-2", subType: AccountSubType.savings, type: AccountType.depository }),
        Account.fromPlain({ id: "acc-3", subType: AccountSubType.brokerage, type: AccountType.investment }),
      ];
      jest.spyOn(Account, "insertMany").mockResolvedValue(mockAccounts as any);
      jest.spyOn(AccountHistory, "insertMany").mockImplementation(async (histories: any) => {
        histories.forEach((h: any, idx: number) => {
          h.account = h.account || mockAccounts[idx % mockAccounts.length];
        });
        return histories;
      });
      jest.spyOn(Category.prototype, "update").mockImplementation(async function (this: any) {
        this.id = this.id || "cat-mock-id";
        return this;
      });
      const catWithId = Category.fromPlain({ id: "cat-1", name: "Expense", user: TestEntities.user });
      jest.spyOn(Category, "find").mockResolvedValue([catWithId]);
      jest.spyOn(Category, "insertMany").mockResolvedValue([]);
      jest.spyOn(Transaction, "insertMany").mockResolvedValue([]);
      jest.spyOn(TransactionRule, "insertMany").mockResolvedValue([]);
      jest.spyOn(Holding, "insertMany").mockResolvedValue([TestEntities.holding] as any);
      jest.spyOn(HoldingHistory, "insertMany").mockResolvedValue([]);
      jest.spyOn(ChatHistory.prototype, "insert").mockResolvedValue({} as any);
      jest.spyOn(ChatOverview, "insertMany").mockResolvedValue([]);

      await service.populateDemoData(30);

      expect(databaseService.source.dropDatabase).toHaveBeenCalled();
      expect(databaseService.executeMigrations).toHaveBeenCalled();

      Configuration.isDemoMode = originalIsDemo;
    });
  });
});
