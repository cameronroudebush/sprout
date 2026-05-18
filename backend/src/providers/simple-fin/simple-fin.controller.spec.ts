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

// Mock static methods on TypeORM models
jest.mock("@backend/account/model/account.model");
jest.mock("@backend/institution/model/institution.model");
jest.mock("@backend/account/model/account.history.model");
jest.mock("@backend/transaction/model/transaction.model");
jest.mock("@backend/holding/model/holding.model");

// Mock crypto module for stable test handling of randomUUID
jest.mock("crypto", () => ({
  randomUUID: () => "mocked-uuid-1234",
}));

describe("SimpleFinProviderController", () => {
  let controller: SimpleFinProviderController;
  let mockSimpleFinProviderService: jest.Mocked<SimpleFINProviderService>;
  let mockSseService: jest.Mocked<SSEService>;
  let mockTransactionRuleService: jest.Mocked<TransactionRuleService>;
  let mockUser: User;

  beforeEach(() => {
    jest.clearAllMocks();

    mockSimpleFinProviderService = {
      get: jest.fn(),
    } as unknown as jest.Mocked<SimpleFINProviderService>;

    mockSseService = {
      sendToUser: jest.fn(),
    } as unknown as jest.Mocked<SSEService>;

    mockTransactionRuleService = {
      applyRulesToTransactions: jest.fn(),
    } as unknown as jest.Mocked<TransactionRuleService>;

    controller = new SimpleFinProviderController(mockSimpleFinProviderService, mockSseService, mockTransactionRuleService);

    mockUser = { id: "user_123" } as User;
  });

  describe("getAccounts", () => {
    it("should return filtered provider accounts when institution exists and some are already synced", async () => {
      const existingAccounts = [{ id: "acc_already_synced" }];
      (Account.find as jest.Mock).mockResolvedValue(existingAccounts);

      const mockInstitution = { id: "inst_99", name: "Chase" };
      (Institution.findOne as jest.Mock).mockResolvedValue(mockInstitution);

      const mockProviderResponse = [
        {
          account: { id: "acc_already_synced", institution: { name: "Chase" } },
        },
        {
          account: { id: "acc_new_1", institution: { name: "Chase" } },
        },
      ];
      mockSimpleFinProviderService.get.mockResolvedValue(mockProviderResponse as any);

      const result = await controller.getAccounts(mockUser);

      expect(Account.find).toHaveBeenCalledWith({ where: { user: { id: "user_123" } } });
      expect(Institution.findOne).toHaveBeenCalledWith({
        where: { user: { id: "user_123" }, name: "Chase" },
      });

      // Verification: The already synced account is filtered out, the new one is retained.
      expect(result).toHaveLength(1);
      expect(result[0]!.id).toBe("acc_new_1");
      expect(result[0]!.institution).toEqual(mockInstitution); // Overwritten with existing institution
    });

    it("should assign a random UUID to a new institution if no matching institution is found", async () => {
      (Account.find as jest.Mock).mockResolvedValue([]);
      (Institution.findOne as jest.Mock).mockResolvedValue(null); // Force branch condition: matchingInstitution == null

      const mockProviderResponse = [
        {
          account: { id: "acc_new_2", institution: { name: "New Bank", id: undefined } },
        },
      ];
      mockSimpleFinProviderService.get.mockResolvedValue(mockProviderResponse as any);

      const result = await controller.getAccounts(mockUser);

      expect(result).toHaveLength(1);
      expect(result[0]!.institution.id).toBe("mocked-uuid-1234");
    });
  });

  describe("linkAccounts", () => {
    it("should process, validate, link, and save matching accounts, transactions, and holdings", async () => {
      const mockAccountInstance = {
        name: "Checking",
        institution: { name: "Chase" },
        insert: jest.fn().mockResolvedValue({ id: "inserted_acc" }),
      };

      const mockProviderData = [
        {
          account: mockAccountInstance,
          transactions: [{ id: "tx_1" }],
          holdings: [{ id: "hold_1" }],
        },
      ];
      mockSimpleFinProviderService.get.mockResolvedValue(mockProviderData as any);

      const mockInstitution = { id: "inst_99", name: "Chase" };
      (Institution.findOne as jest.Mock).mockResolvedValue(mockInstitution);

      // Spy on static validator
      const validateSubTypeSpy = jest.spyOn(Account, "validateSubType").mockImplementation(() => {});
      (Transaction.insertMany as jest.Mock).mockResolvedValue(true);
      (Holding.insertMany as jest.Mock).mockResolvedValue(true);
      (AccountHistory.insertForNewAccount as jest.Mock).mockImplementation(() => {});

      const accountsToLinkFromRequest = [{ name: "Checking", subType: "checking" }] as unknown as [Account];

      const result = await controller.linkAccounts(accountsToLinkFromRequest, mockUser);

      expect(mockSimpleFinProviderService.get).toHaveBeenCalledWith(mockUser, true);
      expect(Institution.findOne).toHaveBeenCalledWith({
        where: { user: { id: "user_123" }, name: "Chase" },
      });

      // Branch evaluation: verified subType string validation executed
      expect(validateSubTypeSpy).toHaveBeenCalledWith("checking");
      expect(mockAccountInstance.insert).toHaveBeenCalledWith(false);

      expect(AccountHistory.insertForNewAccount).toHaveBeenCalledWith({ id: "inserted_acc" });
      expect(Transaction.insertMany).toHaveBeenCalledWith([{ id: "tx_1", account: mockAccountInstance }]);
      expect(mockTransactionRuleService.applyRulesToTransactions).toHaveBeenCalledWith(mockUser, undefined, true);
      expect(Holding.insertMany).toHaveBeenCalledWith([{ id: "hold_1", account: mockAccountInstance }]);

      // SSE Events pipeline validation
      expect(mockSseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
      expect(result).toEqual([mockAccountInstance]);
    });

    it("should fallback institution context user configuration and ignore null subType definitions", async () => {
      const mockAccountInstance = {
        name: "Savings",
        institution: { name: "Unsaved Inst", user: undefined },
        insert: jest.fn().mockResolvedValue({ id: "inserted_savings" }),
      };

      const mockProviderData = [
        {
          account: mockAccountInstance,
          transactions: [],
          holdings: [],
        },
      ];
      mockSimpleFinProviderService.get.mockResolvedValue(mockProviderData as any);
      (Institution.findOne as jest.Mock).mockResolvedValue(null); // Forces else branch: matchingAccount.account.institution.user = user;

      const validateSubTypeSpy = jest.spyOn(Account, "validateSubType");

      const accountsToLinkFromRequest = [
        { name: "Savings", subType: null }, // Forces branch: account.subType != null to evaluate false
      ] as unknown as [Account];

      const result = await controller.linkAccounts(accountsToLinkFromRequest, mockUser);

      expect(mockAccountInstance.institution.user).toEqual(mockUser);
      expect(validateSubTypeSpy).not.toHaveBeenCalled();
      expect(result).toHaveLength(1);
    });

    it("should skip adding any account variants not found within provider runtime contexts", async () => {
      mockSimpleFinProviderService.get.mockResolvedValue([]); // No matching accounts found inside SimpleFin

      const accountsToLinkFromRequest = [{ name: "Ghost Account", subType: "checking" }] as unknown as [Account];

      const result = await controller.linkAccounts(accountsToLinkFromRequest, mockUser);

      // Verify execution skipped processing structures
      expect(Institution.findOne).not.toHaveBeenCalled();
      expect(Transaction.insertMany).not.toHaveBeenCalled();
      expect(mockSseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
      expect(result).toEqual([]); // Returns empty array since matchingAccount was falsy
    });
  });
});
