import { Account } from "@backend/account/model/account.model";
import { AccountType } from "@backend/account/model/account.type";
import { Category } from "@backend/category/model/category.model";
import { Configuration } from "@backend/config/core";
import { Holding } from "@backend/holding/model/holding.model";
import { SimpleFINProviderService } from "@backend/providers/simple-fin/simple-fin.provider.service";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { BadRequestException } from "@nestjs/common";
import { ProviderRateLimit } from "../base/rate-limit";

// Mock external dependencies and configuration
jest.mock("@backend/config/core", () => ({
  Configuration: {
    providers: {
      simpleFIN: {
        rateLimit: 100,
      },
      lookBackDays: 30,
    },
    encryptionKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
  },
}));

jest.mock("../base/rate-limit");
jest.mock("@backend/account/model/account.model");
jest.mock("@backend/holding/model/holding.model");
jest.mock("@backend/category/model/category.model");
jest.mock("@backend/transaction/model/transaction.model");

describe("SimpleFINProviderService", () => {
  let service: SimpleFINProviderService;
  let mockUser: User;
  let mockIncrementOrError: jest.Mock;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new SimpleFINProviderService();

    mockUser = {
      config: {
        simpleFinToken: "https://username:password@bridge.simplefin.org",
      },
    } as unknown as User;

    mockIncrementOrError = jest.fn().mockResolvedValue(undefined);
    (ProviderRateLimit as unknown as jest.Mock).mockImplementation(() => ({
      incrementOrError: mockIncrementOrError,
    }));

    // Mock global fetch
    global.fetch = jest.fn();
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

  describe("determineAccountType (Branch Coverage)", () => {
    // Accessing private method via bracket notation or cast for testing purposes
    const determineType = (name: string, balance: number, holdings: any[]) => (service as any).determineAccountType(name, balance, holdings);

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
  });

  describe("fetchData", () => {
    it("should throw an error if the user simpleFinToken is missing", async () => {
      const invalidUser = { config: {} } as User;
      await expect(service.fetchData(undefined, undefined, false, invalidUser)).rejects.toThrow("SimpleFIN access token is not properly configured.");
    });

    it("should execute fetch successfully with correctly parsed authorization and URLs", async () => {
      const mockJsonResponse = { accounts: [] };
      (global.fetch as jest.Mock).mockResolvedValue({
        json: jest.fn().mockResolvedValue(mockJsonResponse),
      });

      const result = await service.fetchData(undefined, undefined, false, mockUser);

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

  describe("get & convertData", () => {
    it("should handle transformation of accounts, errors, holdings, and transactions", async () => {
      const mockFinancialData = {
        errors: ["Error on Chase"],
        accounts: [
          {
            id: "acc_1",
            name: "Chase Card",
            balance: "-250.00",
            "available-balance": "5000.00",
            currency: "USD",
            extra: { note: "primary" },
            org: { name: "Chase", url: "https://chase.com" },
            holdings: [
              {
                id: "hold_1",
                currency: "USD",
                cost_basis: "100.00",
                description: "Apple Stock",
                market_value: "150.00",
                purchase_price: "90.00",
                shares: "1.5",
                symbol: "AAPL",
              },
            ],
            transactions: [
              {
                id: "tx_1",
                posted: 1715900000, // Epoch timestamp
                amount: -25.5,
                description: "Starbucks",
                pending: true,
                extra: { category: "Food" },
              },
            ],
          },
        ],
      };

      // Mock spy on internal fetchData
      jest.spyOn(service, "fetchData").mockResolvedValue(mockFinancialData as any);

      // Setup implementation for static factory methods to return dummy values
      (Account.fromPlain as jest.Mock).mockReturnValue({ id: "mock_account" });
      (Holding.fromPlain as jest.Mock).mockReturnValue({ id: "mock_holding" });
      (Category.getOrCreate as jest.Mock).mockResolvedValue({ id: "mock_category" });
      (Transaction.fromPlain as jest.Mock).mockReturnValue({ id: "mock_tx" });

      const result = await service.get(mockUser, false);

      expect(service.fetchData).toHaveBeenCalledWith(undefined, undefined, false, mockUser);
      expect(Account.fromPlain).toHaveBeenCalledWith(
        expect.objectContaining({
          id: "acc_1",
          balance: -250,
          availableBalance: 5000,
          type: AccountType.credit, // Because balance <= 0 and name includes 'card'
          institution: expect.objectContaining({
            name: "Chase",
            hasError: true, // "Error on Chase" matched the error list
          }),
        }),
      );

      expect(Holding.fromPlain).toHaveBeenCalledWith(
        expect.objectContaining({
          id: "hold_1",
          costBasis: 100,
          marketValue: 150,
          shares: 1.5,
        }),
      );

      expect(Category.getOrCreate).toHaveBeenCalledWith("Food", mockUser);
      expect(Transaction.fromPlain).toHaveBeenCalledWith(
        expect.objectContaining({
          id: "tx_1",
          pending: true,
          posted: new Date(1715900000 * 1000),
        }),
      );

      expect(result).toEqual([
        {
          account: { id: "mock_account" },
          holdings: [{ id: "mock_holding" }],
          transactions: [{ id: "mock_tx" }],
        },
      ]);
    });

    it("should fallback transaction pending value to false if undefined", async () => {
      const mockFinancialDataWithMissingPending = {
        errors: [],
        accounts: [
          {
            id: "acc_2",
            name: "Checking",
            balance: "100.00",
            "available-balance": "100.00",
            org: { name: "Bank", url: "url" },
            holdings: [],
            transactions: [
              {
                id: "tx_2",
                posted: 1715900000,
                amount: -10,
                description: "Gas",
                pending: undefined, // Test the ?? false fallback branch
              },
            ],
          },
        ],
      };

      jest.spyOn(service, "fetchData").mockResolvedValue(mockFinancialDataWithMissingPending as any);

      await service.get(mockUser, false);

      expect(Transaction.fromPlain).toHaveBeenCalledWith(
        expect.objectContaining({
          id: "tx_2",
          pending: false,
        }),
      );
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

      await expect(service.convertSetupToken(validUrlToken)).rejects.toThrow("Failed to exchange token. Status: 400.");
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
});
