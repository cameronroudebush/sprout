import { Account } from "@backend/account/model/account.model";
import { AccountSubType } from "@backend/account/model/account.sub.type";
import { AccountType } from "@backend/account/model/account.type";
import { Category } from "@backend/category/model/category.model";
import { Configuration } from "@backend/config/core";
import { Institution } from "@backend/institution/model/institution.model";
import { SimpleFINProviderService } from "@backend/providers/simple-fin/simple-fin.provider.service";
import { User } from "@backend/user/model/user.model";
import { BadRequestException } from "@nestjs/common";
import { ProviderRateLimit } from "../base/rate-limit";

jest.mock("@backend/config/core", () => ({
  Configuration: {
    providers: {
      simpleFIN: {
        rateLimit: 100,
        lookBackDays: 30,
      },
    },
    server: {
      basePath: "/api",
    },
    encryptionKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
  },
}));

jest.mock("../base/rate-limit");
jest.mock("@backend/account/model/account.model");
jest.mock("@backend/holding/model/holding.model");
jest.mock("@backend/category/model/category.model");
jest.mock("@backend/transaction/model/transaction.model");
jest.mock("@backend/institution/model/institution.model");

describe("SimpleFINProviderService", () => {
  let service: SimpleFINProviderService;
  let mockUser: User;
  let mockIncrementOrError: jest.Mock;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new SimpleFINProviderService();

    mockUser = {
      id: "user_1",
      config: {
        simpleFinToken: "https://username:password@bridge.simplefin.org",
        update: jest.fn().mockResolvedValue(true),
      },
    } as unknown as User;

    mockIncrementOrError = jest.fn().mockResolvedValue(undefined);
    (ProviderRateLimit as unknown as jest.Mock).mockImplementation(() => ({
      incrementOrError: mockIncrementOrError,
    }));
    global.fetch = jest.fn();

    // Setup base TypeORM mock returns
    Account.find = jest.fn().mockResolvedValue([]);
    Account.fromPlain = jest.fn().mockImplementation((val) => val);
  });

  describe("Configuration & Getters", () => {
    it("should return correct app configuration", () => {
      expect(service.getAppConfiguration()).toEqual(Configuration.providers.simpleFIN);
    });

    it("should return expected configuration defaults", () => {
      expect(service.config.name).toBe("SimpleFIN");
      expect(service.config.url).toBe("https://www.simplefin.org/");
    });

    it("should instantiate and return rateLimit", () => {
      const rateLimitInstance = service.rateLimit(mockUser);
      expect(ProviderRateLimit).toHaveBeenCalledWith("simple-fin", Configuration.providers.simpleFIN.rateLimit, mockUser);
      expect(rateLimitInstance).toBeDefined();
    });

    it("should return availability based on user token status", async () => {
      await expect(service.isAvailable(mockUser)).resolves.toBe(true);

      const userWithoutToken = { config: {} } as User;
      await expect(service.isAvailable(userWithoutToken)).resolves.toBe(false);
    });
  });

  describe("Base Utilities (Branch Coverage)", () => {
    const determineType = (name: string, balance: number, holdings: any[]) => (service as any).determineAccountType(name, balance, holdings.length > 0);
    const determineSubType = (name: string) => (service as any).determineAccountSubType(name);

    it("should return credit when balance <= 0 and name contains keyword", () => {
      expect(determineType("My Visa Card", -500, [])).toBe(AccountType.credit);
    });

    it("should return crypto when name contains crypto keywords", () => {
      expect(determineType("Solana Wallet", 100, [])).toBe(AccountType.crypto);
    });

    it("should return investment when holdings are present or name contains keyword", () => {
      expect(determineType("Regular Checking", 0, [{ id: "h1" }])).toBe(AccountType.investment);
      expect(determineType("My Roth IRA", 0, [])).toBe(AccountType.investment);
    });

    it("should return depository when balance > 0 and no other rules match", () => {
      expect(determineType("Random Asset", 1500, [])).toBe(AccountType.depository);
    });

    it("should fallback to loan when balance <= 0 and no keywords match", () => {
      expect(determineType("Mystery Account", -100, [])).toBe(AccountType.loan);
    });

    it("should accurately determine subtypes regardless of spacing or case", () => {
      expect(determineSubType("Roth IRA")).toBe(AccountSubType.ira);
      expect(determineSubType("My 401(k) Plan")).toBe(AccountSubType["401k"]);
      expect(determineSubType("Free Checking")).toBe(AccountSubType.checking);
      expect(determineSubType("High Yield Savings")).toBe(AccountSubType.savings);
      expect(determineSubType("Unknown")).toBe(AccountSubType.other);
    });
  });

  describe("fetchData", () => {
    it("should execute fetch successfully with correctly parsed authorization and URLs", async () => {
      const mockJsonResponse = { accounts: [] };
      (global.fetch as jest.Mock).mockResolvedValue({
        json: jest.fn().mockResolvedValue(mockJsonResponse),
      });

      const result = await (service as any).fetchData("https://username:password@bridge.simplefin.org", false, mockUser);

      expect(mockIncrementOrError).toHaveBeenCalled();
      expect(global.fetch).toHaveBeenCalledWith(
        expect.stringContaining("https://bridge.simplefin.org/accounts?pending=1"),
        expect.objectContaining({
          method: "GET",
          headers: {
            Authorization: expect.stringContaining("Basic "),
          },
        }),
      );
      expect(result).toEqual(mockJsonResponse);
    });
  });

  describe("convertSetupToken", () => {
    it("should throw BadRequestException if setupToken cannot be decoded to a valid URL", async () => {
      const invalidToken = Buffer.from("not-a-url").toString("base64");
      await expect(service.convertSetupToken(invalidToken)).rejects.toThrow(BadRequestException);
    });

    it("should throw an error if the claim endpoint returns a non-OK status", async () => {
      const validUrlToken = Buffer.from("https://bridge.simplefin.org/claim").toString("base64");
      (global.fetch as jest.Mock).mockResolvedValue({
        ok: false,
        status: 400,
      });

      await expect(service.convertSetupToken(validUrlToken)).rejects.toThrow("Failed to exchange SimpleFIN token.");
    });

    it("should return access token text on successful exchange", async () => {
      const validUrlToken = Buffer.from("https://bridge.simplefin.org/claim").toString("base64");
      (global.fetch as jest.Mock).mockResolvedValue({
        ok: true,
        text: jest.fn().mockResolvedValue("generated-access-token-string"),
      });

      const token = await service.convertSetupToken(validUrlToken);

      expect(global.fetch).toHaveBeenCalledWith("https://bridge.simplefin.org/claim", {
        method: "POST",
        headers: { "Content-Length": "0" },
      });
      expect(token).toBe("generated-access-token-string");
    });
  });

  describe("getUnlinkedAccounts", () => {
    it("should fetch remote accounts and filter out those that already exist locally", async () => {
      // Mock local DB having acc_1
      Account.find = jest.fn().mockResolvedValue([{ id: "acc_1" }]);

      // Mock remote SimpleFIN returning acc_1 and acc_2
      jest.spyOn(service as any, "fetchData").mockResolvedValue({
        accounts: [
          { id: "acc_1", name: "Old", balance: "0", "available-balance": "0", currency: "USD", org: { name: "Bank", url: "url" } },
          { id: "acc_2", name: "New", balance: "100", "available-balance": "100", currency: "USD", org: { name: "Bank", url: "url" } },
        ],
      });

      const unlinked = await service.getUnlinkedAccounts(mockUser);

      // Should only return acc_2
      expect(unlinked).toHaveLength(1);
      expect(unlinked[0]?.id).toBe("acc_2");
      expect(unlinked[0]?.name).toBe("New");
    });
  });

  describe("performExchange", () => {
    it("should fetch remote accounts, filter to requested IDs, and group them by Institution name", async () => {
      jest.spyOn(service as any, "fetchData").mockResolvedValue({
        accounts: [
          { id: "acc_1", name: "Chase Checking", org: { name: "Chase", url: "chase.com" } },
          { id: "acc_2", name: "Chase Savings", org: { name: "Chase", url: "chase.com" } },
          { id: "acc_3", name: "Citi Card", org: { name: "Citi", url: "citi.com" } },
        ],
      });

      // User only wants to link acc_1 and acc_3
      const result = await (service as any).performExchange(mockUser, ["acc_1", "acc_3"]);

      expect(result).toHaveLength(2); // Grouped into Chase and Citi

      const chaseGroup = result.find((r: any) => r.institutionName === "Chase");
      expect(chaseGroup.rawAccounts).toHaveLength(1);
      expect(chaseGroup.rawAccounts[0].id).toBe("acc_1");

      const citiGroup = result.find((r: any) => r.institutionName === "Citi");
      expect(citiGroup.rawAccounts[0].id).toBe("acc_3");
    });
  });

  describe("mapToSproutAccount", () => {
    it("should convert raw SimpleFIN account data to an Account entity and manually assign the ID", async () => {
      const rawAccount = {
        id: "fin_id_123",
        name: "My Checking",
        balance: "50.00",
        "available-balance": "100.00",
        currency: "USD",
        holdings: [],
      };

      const mockInstitution = new Institution("url", "Bank", false, mockUser);

      const result = await (service as any).mapToSproutAccount(rawAccount, "authContext", mockUser, mockInstitution);

      expect(result.id).toBe("fin_id_123"); // ID assignment is critical for SimpleFIN
    });
  });

  describe("fetchInitialSyncData", () => {
    it("should extract holdings and transactions from the raw payload", async () => {
      const rawAccount = {
        holdings: [{ symbol: "AAPL", shares: "10", market_value: "1500" }],
        transactions: [{ id: "tx_1", amount: "-10", posted: 1715900000, description: "Coffee", extra: { category: "Food" } }],
      };
      const mockAccount = { id: "acc_1" } as Account;

      (Category.getOrCreate as jest.Mock).mockResolvedValue({ id: "cat_food" });

      const result = await (service as any).fetchInitialSyncData(rawAccount, mockAccount, "auth", mockUser);

      expect(result.holdings).toHaveLength(1);

      expect(result.transactions).toHaveLength(1);
    });
  });
});
