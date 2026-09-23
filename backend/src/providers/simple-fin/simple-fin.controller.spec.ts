import { setupTests } from "@backend/test/helpers";
setupTests();

import { SimpleFinProviderController } from "@backend/providers/simple-fin/simple-fin.controller";
import { SimpleFINProviderService } from "@backend/providers/simple-fin/simple-fin.provider.service";
import { SSEService } from "@backend/sse/sse.service";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { TestEntities } from "@backend/test/entities";
import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { SSEEventType } from "@backend/sse/model/event.model";

describe("SimpleFinProviderController", () => {
  let controller: SimpleFinProviderController;
  let simpleFinService: Mocked<SimpleFINProviderService>;
  let sseService: Mocked<SSEService>;
  let transactionRuleService: Mocked<TransactionRuleService>;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.clearAllMocks();

    simpleFinService = {
      getUnlinkedAccounts: vi.fn(),
      exchangeAndCreateAccounts: vi.fn(),
    } as any;

    sseService = {
      sendToUser: vi.fn(),
    } as any;

    transactionRuleService = {
      applyRulesToTransactions: vi.fn().mockResolvedValue(undefined),
    } as any;

    controller = new SimpleFinProviderController(simpleFinService, sseService, transactionRuleService);
  });

  describe("getAccounts", () => {
    it("should return unlinked accounts from simpleFinProviderService", async () => {
      const accounts = [TestEntities.account];
      simpleFinService.getUnlinkedAccounts.mockResolvedValue(accounts as any);

      const res = await controller.getAccounts(user);

      expect(simpleFinService.getUnlinkedAccounts).toHaveBeenCalledWith(user);
      expect(res).toBe(accounts);
    });
  });

  describe("linkAccounts", () => {
    it("should link accounts, apply frontend overrides, apply rules, and force update", async () => {
      const accountToLink = TestEntities.account;
      accountToLink.subType = AccountSubType.checking;

      const mockSyncResult = {
        account: Account.fromPlain({ id: accountToLink.id, name: "Test" }),
      };
      mockSyncResult.account.update = vi.fn().mockResolvedValue(mockSyncResult.account);

      simpleFinService.exchangeAndCreateAccounts.mockResolvedValue([mockSyncResult] as any);

      const res = await controller.linkAccounts([accountToLink], user);

      expect(simpleFinService.exchangeAndCreateAccounts).toHaveBeenCalledWith(user, [accountToLink.id]);
      expect(transactionRuleService.applyRulesToTransactions).toHaveBeenCalledWith(user, undefined, true);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res.length).toBe(1);
    });

    it("should link accounts without applying an absent subtype override", async () => {
      const resultAccount = Account.fromPlain({ id: "result", name: "Result" });
      resultAccount.update = vi.fn().mockResolvedValue(resultAccount);
      simpleFinService.exchangeAndCreateAccounts.mockResolvedValue([{ account: resultAccount }] as any);

      const res = await controller.linkAccounts([], user);

      expect(resultAccount.update).not.toHaveBeenCalled();
      expect(res).toEqual([resultAccount]);
    });
  });
});
