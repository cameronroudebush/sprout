import { Account } from "@backend/account/model/account.model";
import { SimpleFinProviderController } from "@backend/providers/simple-fin/simple-fin.controller";
import { SimpleFINProviderService } from "@backend/providers/simple-fin/simple-fin.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";
import { Test, TestingModule } from "@nestjs/testing";

describe("SimpleFinProviderController", () => {
  let controller: SimpleFinProviderController;
  let simpleFinProviderService: jest.Mocked<SimpleFINProviderService>;
  let sseService: jest.Mocked<SSEService>;
  let transactionRuleService: jest.Mocked<TransactionRuleService>;

  const mockUser = { id: "user-id-abc" } as User;

  beforeEach(async () => {
    const mockSimpleFinProviderService = {
      getUnlinkedAccounts: jest.fn(),
      exchangeAndCreateAccounts: jest.fn(),
    };
    const mockSseService = { sendToUser: jest.fn() };
    const mockTransactionRuleService = { applyRulesToTransactions: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [SimpleFinProviderController],
      providers: [
        { provide: SimpleFINProviderService, useValue: mockSimpleFinProviderService },
        { provide: SSEService, useValue: mockSseService },
        { provide: TransactionRuleService, useValue: mockTransactionRuleService },
      ],
    }).compile();

    controller = module.get<SimpleFinProviderController>(SimpleFinProviderController);
    simpleFinProviderService = module.get(SimpleFINProviderService);
    sseService = module.get(SSEService);
    transactionRuleService = module.get(TransactionRuleService);

    jest.clearAllMocks();
  });

  describe("getAccounts", () => {
    it("should return un-synced provider accounts directly from the service", async () => {
      const mockUnlinkedAccounts = [
        { id: "acc-new-1", name: "Bank A Checking" },
        { id: "acc-new-2", name: "Bank B Savings" },
      ];

      simpleFinProviderService.getUnlinkedAccounts.mockResolvedValue(mockUnlinkedAccounts as any);

      const result = await controller.getAccounts(mockUser);

      expect(simpleFinProviderService.getUnlinkedAccounts).toHaveBeenCalledWith(mockUser);
      expect(result).toHaveLength(2);
      expect(result[0]!.id).toBe("acc-new-1");
    });
  });

  describe("linkAccounts", () => {
    it("should pass account IDs to exchangeAndCreateAccounts, run rules, and trigger SSE", async () => {
      const accountsToLink = [Account.fromPlain({ id: "acc-1", name: "Checking Account", subType: null })];

      const mockSyncResult = [
        {
          account: { id: "acc-1", name: "Checking Account", update: jest.fn().mockResolvedValue(true) },
        },
      ];

      simpleFinProviderService.exchangeAndCreateAccounts.mockResolvedValue(mockSyncResult as any);

      const result = await controller.linkAccounts(accountsToLink, mockUser);

      expect(simpleFinProviderService.exchangeAndCreateAccounts).toHaveBeenCalledWith(mockUser, ["acc-1"]);
      expect(transactionRuleService.applyRulesToTransactions).toHaveBeenCalledWith(mockUser, undefined, true);
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);

      expect(result).toHaveLength(1);
      expect(result[0]!.id).toBe("acc-1");
    });

    it("should apply frontend subtype overrides, validate them, and update the account if provided", async () => {
      const accountsToLink = [Account.fromPlain({ id: "acc-1", name: "Checking Account", subType: "checking" })];

      const mockSyncResult = [
        {
          account: {
            id: "acc-1",
            name: "Checking Account",
            subType: "other", // Pretend the provider initially assigned 'other'
            update: jest.fn().mockResolvedValue(true),
          },
        },
      ];

      simpleFinProviderService.exchangeAndCreateAccounts.mockResolvedValue(mockSyncResult as any);
      const validateSubTypeSpy = jest.spyOn(Account, "validateSubType").mockImplementation(() => {});

      const result = await controller.linkAccounts(accountsToLink, mockUser);

      // Verify the frontend override was applied and saved
      const updatedAccount = result[0]!;
      expect(updatedAccount.subType).toBe("checking");
      expect(validateSubTypeSpy).toHaveBeenCalledWith("checking");
      expect(mockSyncResult[0]?.account.update).toHaveBeenCalled();
    });

    it("should not validate or update the account if no subtype override is provided", async () => {
      const accountsToLink = [
        { id: "acc-2", name: "Savings Account" }, // Missing subType
      ] as Account[];

      const mockSyncResult = [
        {
          account: {
            id: "acc-2",
            name: "Savings Account",
            subType: "savings",
            update: jest.fn().mockResolvedValue(true),
          },
        },
      ];

      simpleFinProviderService.exchangeAndCreateAccounts.mockResolvedValue(mockSyncResult as any);
      const validateSubTypeSpy = jest.spyOn(Account, "validateSubType");

      const result = await controller.linkAccounts(accountsToLink, mockUser);

      // Verify it skipped the override process
      expect(validateSubTypeSpy).not.toHaveBeenCalled();
      expect(mockSyncResult[0]?.account.update).not.toHaveBeenCalled();
      expect(result[0]!.subType).toBe("savings");
    });
  });
});
