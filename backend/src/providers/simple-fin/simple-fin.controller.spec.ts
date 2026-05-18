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

describe("SimpleFinProviderController", () => {
  let controller: SimpleFinProviderController;
  let simpleFinProviderService: SimpleFINProviderService;
  let sseService: SSEService;
  let transactionRuleService: TransactionRuleService;

  const mockUser = { id: "user-123" } as User;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [SimpleFinProviderController],
      providers: [
        {
          provide: SimpleFINProviderService,
          useValue: {
            get: jest.fn(),
          },
        },
        {
          provide: SSEService,
          useValue: {
            sendToUser: jest.fn(),
          },
        },
        {
          provide: TransactionRuleService,
          useValue: {
            applyRulesToTransactions: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<SimpleFinProviderController>(SimpleFinProviderController);
    simpleFinProviderService = module.get<SimpleFINProviderService>(SimpleFINProviderService);
    sseService = module.get<SSEService>(SSEService);
    transactionRuleService = module.get<TransactionRuleService>(TransactionRuleService);

    // Setup TypeORM method mocks
    Account.find = jest.fn();
    Account.validateSubType = jest.fn();
    Institution.findOne = jest.fn();
    AccountHistory.insertForNewAccount = jest.fn();
    Transaction.insertMany = jest.fn();
    Holding.insertMany = jest.fn();
  });

  describe("getAccounts", () => {
    it("should return accounts not already linked (existing institution)", async () => {
      const existingAccounts = [{ id: "acc-1" }];
      (Account.find as jest.Mock).mockResolvedValue(existingAccounts);

      const mockProviderAccounts = [
        { account: { id: "acc-1", institution: { name: "Bank A" } } }, // Already linked
        { account: { id: "acc-2", institution: { name: "Bank B", id: "old-uuid" } } }, // New
      ];
      (simpleFinProviderService.get as jest.Mock).mockResolvedValue(mockProviderAccounts);

      const matchingInstitution = { id: "inst-1", name: "Bank B" };
      (Institution.findOne as jest.Mock).mockResolvedValue(matchingInstitution);

      const result = await controller.getAccounts(mockUser);

      expect(result).toHaveLength(1);
      expect(result[0]!.id).toBe("acc-2");
      expect(result[0]!.institution).toEqual(matchingInstitution);
      expect(Institution.findOne).toHaveBeenCalledWith({ where: { user: { id: mockUser.id }, name: "Bank B" } });
    });

    it("should assign a new UUID to institution if no matching institution exists", async () => {
      const existingAccounts: Account[] = [];
      (Account.find as jest.Mock).mockResolvedValue(existingAccounts);

      const mockProviderAccounts = [{ account: { id: "acc-2", institution: { name: "Bank B", id: "old-uuid" } } }];
      (simpleFinProviderService.get as jest.Mock).mockResolvedValue(mockProviderAccounts);

      (Institution.findOne as jest.Mock).mockResolvedValue(null);

      const result = await controller.getAccounts(mockUser);

      expect(result).toHaveLength(1);
      expect(result[0]!.id).toBe("acc-2");
      expect(result[0]!.institution.id).not.toBe("old-uuid");
      expect(result[0]!.institution.id).toBeDefined();
    });
  });

  describe("linkAccounts", () => {
    it("should link valid accounts and save to database with existing institution", async () => {
      const accountsToLink = [{ name: "Checking", subType: "checking" }] as unknown as Account[];

      const insertMock = jest.fn().mockResolvedValue({ id: "acc-1", name: "Checking" });
      const mockProviderAccounts = [
        {
          account: { id: "acc-1", name: "Checking", institution: { name: "Bank A" }, insert: insertMock },
          transactions: [{ id: "t1" }],
          holdings: [{ id: "h1" }],
        },
      ];

      (simpleFinProviderService.get as jest.Mock).mockResolvedValue(mockProviderAccounts);
      const matchingInstitution = { id: "inst-1", name: "Bank A" };
      (Institution.findOne as jest.Mock).mockResolvedValue(matchingInstitution);

      const result = await controller.linkAccounts(accountsToLink as any, mockUser);

      expect(result).toHaveLength(1);
      expect(result[0]!.id).toBe("acc-1");
      expect(mockProviderAccounts[0]!.account.institution).toEqual(matchingInstitution);
      expect(Account.validateSubType).toHaveBeenCalledWith("checking");
      expect(insertMock).toHaveBeenCalledWith(false);
      expect(AccountHistory.insertForNewAccount).toHaveBeenCalled();
      expect(Transaction.insertMany).toHaveBeenCalled();
      expect(transactionRuleService.applyRulesToTransactions).toHaveBeenCalledWith(mockUser, undefined, true);
      expect(Holding.insertMany).toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
    });

    it("should link valid accounts and handle missing institution creation", async () => {
      const accountsToLink = [{ name: "Checking" }] as unknown as Account[];

      const insertMock = jest.fn().mockResolvedValue({ id: "acc-1", name: "Checking" });
      const mockProviderAccounts = [
        {
          account: { name: "Checking", institution: { name: "Bank A" }, insert: insertMock },
          transactions: [],
          holdings: [],
        },
      ];

      (simpleFinProviderService.get as jest.Mock).mockResolvedValue(mockProviderAccounts);
      (Institution.findOne as jest.Mock).mockResolvedValue(null);

      await controller.linkAccounts(accountsToLink as any, mockUser);

      // Ensures the fallback correctly applies the user to the institution
      expect((mockProviderAccounts[0]!.account.institution as any).user).toEqual(mockUser);
    });

    it("should skip accounts that don't match provider data", async () => {
      const accountsToLink = [{ name: "Unknown" }] as unknown as Account[];
      const mockProviderAccounts = [{ account: { name: "Checking" }, transactions: [], holdings: [] }];

      (simpleFinProviderService.get as jest.Mock).mockResolvedValue(mockProviderAccounts);

      const result = await controller.linkAccounts(accountsToLink as any, mockUser);

      expect(result).toHaveLength(0);
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
      expect(Institution.findOne).not.toHaveBeenCalled();
    });
  });
});
