import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { SimpleFinProviderController } from "@backend/providers/simple-fin/simple-fin.controller";
import { SimpleFINProviderService } from "@backend/providers/simple-fin/simple-fin.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { User } from "@backend/user/model/user.model";
import { Test, TestingModule } from "@nestjs/testing";

// Explicitly provide structural placeholders for inherited methods so spyOn can bind to them
jest.mock("@backend/account/model/account.model", () => {
  return {
    Account: {
      find: jest.fn(),
      validateSubType: jest.fn(),
      fromPlain: () => {}, // Added placeholder so spyOn works flawlessly
    },
  };
});

jest.mock("@backend/institution/model/institution.model");
jest.mock("@backend/account/model/account.history.model");
jest.mock("@backend/transaction/model/transaction.model");
jest.mock("@backend/holding/model/holding.model");
jest.mock("crypto", () => ({
  randomUUID: () => "mocked-uuid-1234",
}));

describe("SimpleFinProviderController", () => {
  let controller: SimpleFinProviderController;
  let simpleFinProviderService: jest.Mocked<SimpleFINProviderService>;
  let sseService: jest.Mocked<SSEService>;
  let transactionRuleService: jest.Mocked<TransactionRuleService>;

  const mockUser = { id: "user-id-abc" } as User;

  beforeEach(async () => {
    const mockSimpleFinProviderService = { get: jest.fn() };
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
    it("should return un-synced provider accounts, creating a new institution UUID if none exists", async () => {
      const mockExistingAccounts = [{ id: "acc-already-synced" }] as Account[];
      jest.spyOn(Account, "find").mockResolvedValue(mockExistingAccounts);

      const mockProviderResponse = [
        {
          account: { id: "acc-already-synced", institution: { name: "Bank A" } },
        },
        {
          account: { id: "acc-new-1", institution: { name: "Bank B" } },
        },
      ];
      simpleFinProviderService.get.mockResolvedValue(mockProviderResponse as any);
      jest.spyOn(Institution, "findOne").mockResolvedValue(null);

      const result = await controller.getAccounts(mockUser);

      expect(Account.find).toHaveBeenCalledWith({ where: { user: { id: "user-id-abc" } } });
      expect(Institution.findOne).toHaveBeenCalledTimes(2);

      expect(result).toHaveLength(1);
      expect(result[0]!.id).toBe("acc-new-1");
      expect(result[0]!.institution.id).toBe("mocked-uuid-1234");
    });

    it("should reuse an existing institution if a matching one is found", async () => {
      jest.spyOn(Account, "find").mockResolvedValue([]);

      const existingInstitution = { id: "inst-existing", name: "Bank A" };
      jest.spyOn(Institution, "findOne").mockResolvedValue(existingInstitution as any);

      const mockProviderResponse = [{ account: { id: "acc-new-2", institution: { name: "Bank A" } } }];
      simpleFinProviderService.get.mockResolvedValue(mockProviderResponse as any);

      const result = await controller.getAccounts(mockUser);

      expect(result).toHaveLength(1);
      expect(result[0]!.institution).toEqual(existingInstitution);
    });
  });

  describe("linkAccounts", () => {
    it("should link accounts, execute histories, transactions, rules, holdings, and send SSE updates", async () => {
      jest.spyOn(Account, "fromPlain").mockReturnValue({ name: "Checking Account", subType: "checking" } as any);
      const accountsToLink = [Account.fromPlain({ name: "Checking Account", subType: "checking" })];

      const mockAccountInstance = {
        name: "Checking Account",
        institution: { name: "Chase Bank" },
        subType: null,
        user: null,
        insert: jest.fn().mockResolvedValue({ id: "inserted-acc-id" }),
      };

      const mockProviderResponse = [
        {
          account: mockAccountInstance,
          transactions: [{ id: "tx-1" }],
          holdings: [{ id: "h-1" }],
        },
      ];
      simpleFinProviderService.get.mockResolvedValue(mockProviderResponse as any);

      const mockMatchingInstitution = { id: "inst-chase", name: "Chase Bank" };
      jest.spyOn(Institution, "findOne").mockResolvedValue(mockMatchingInstitution as any);

      const validateSubTypeSpy = jest.spyOn(Account, "validateSubType").mockImplementation(() => {});
      const insertForNewAccountSpy = jest.spyOn(AccountHistory, "insertForNewAccount").mockImplementation((() => {}) as any);
      jest.spyOn(Transaction, "insertMany").mockResolvedValue([] as any);
      jest.spyOn(Holding, "insertMany").mockResolvedValue([] as any);

      const result = await controller.linkAccounts(accountsToLink as [Account], mockUser);

      expect(mockAccountInstance.user).toBe(mockUser);
      expect(mockAccountInstance.institution).toBe(mockMatchingInstitution);
      expect(mockAccountInstance.subType).toBe("checking");
      expect(validateSubTypeSpy).toHaveBeenCalledWith("checking");

      expect(mockAccountInstance.insert).toHaveBeenCalledWith(false);
      expect(insertForNewAccountSpy).toHaveBeenCalledWith({ id: "inserted-acc-id" });
      expect(Transaction.insertMany).toHaveBeenCalledWith([{ id: "tx-1", account: mockAccountInstance }]);
      expect(Holding.insertMany).toHaveBeenCalledWith([{ id: "h-1", account: mockAccountInstance }]);
      expect(transactionRuleService.applyRulesToTransactions).toHaveBeenCalledWith(mockUser, undefined, true);

      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
      expect(result).toHaveLength(1);
      expect(result[0]!.name).toBe("Checking Account");
    });

    it("should assign user to institution if institution doesn't exist, and skip validateSubType if subType is missing", async () => {
      jest.spyOn(Account, "fromPlain").mockReturnValue({ name: "Savings Account", subType: null } as any);
      const accountsToLink = [Account.fromPlain({ name: "Savings Account", subType: null })];

      const mockAccountInstance = {
        name: "Savings Account",
        institution: { name: "New Bank", user: null },
        subType: null,
        user: null,
        insert: jest.fn().mockResolvedValue({ id: "inserted-savings-id" }),
      };

      const mockProviderResponse = [
        {
          account: mockAccountInstance,
          transactions: [],
          holdings: [],
        },
      ];
      simpleFinProviderService.get.mockResolvedValue(mockProviderResponse as any);
      jest.spyOn(Institution, "findOne").mockResolvedValue(null);

      const validateSubTypeSpy = jest.spyOn(Account, "validateSubType");
      jest.spyOn(AccountHistory, "insertForNewAccount").mockImplementation((() => {}) as any);
      jest.spyOn(Transaction, "insertMany").mockResolvedValue([] as any);
      jest.spyOn(Holding, "insertMany").mockResolvedValue([] as any);

      const result = await controller.linkAccounts(accountsToLink as [Account], mockUser);

      expect(mockAccountInstance.institution.user).toBe(mockUser);
      expect(validateSubTypeSpy).not.toHaveBeenCalled();
      expect(result).toHaveLength(1);
    });

    it("should skip adding the account if it does not match any provider account", async () => {
      const accountsToLink = [{ name: "Phantom Account" } as Account];

      const mockProviderResponse = [
        {
          account: { name: "Real Account", institution: { name: "Real Bank" } },
          transactions: [],
          holdings: [],
        },
      ];
      simpleFinProviderService.get.mockResolvedValue(mockProviderResponse as any);

      const result = await controller.linkAccounts(accountsToLink as [Account], mockUser);

      expect(AccountHistory.insertForNewAccount).not.toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
      expect(result).toHaveLength(0);
    });
  });
});
