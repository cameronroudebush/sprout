import { Account } from "@backend/account/model/account.model.js";
import { AccountSubType } from "@backend/account/model/account.sub.type.js";
import { AccountType } from "@backend/account/model/account.type.js";
import { Category } from "@backend/category/model/category.model.js";
import { Configuration } from "@backend/config/core.js";
import { Institution } from "@backend/institution/model/institution.model.js";
import { SimpleFINProviderService } from "@backend/providers/simple-fin/simple-fin.provider.service.js";
import { User } from "@backend/user/model/user.model.js";
import { BadRequestException, NotImplementedException } from "@nestjs/common";
import { ProviderRateLimit } from "../base/rate-limit.js";

vi.mock("@backend/config/core", () => ({
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

const mockIncrementOrError = vi.fn().mockResolvedValue(undefined);

vi.mock("../base/rate-limit.js", () => {
  const ProviderRateLimitMock = vi.fn().mockImplementation(function (this: any) {
    this.incrementOrError = mockIncrementOrError;
    return this;
  });
  return {
    ProviderRateLimit: ProviderRateLimitMock,
  };
});

describe("SimpleFINProviderService", () => {
  let service: SimpleFINProviderService;
  let mockUser: User;

  beforeEach(() => {
    vi.restoreAllMocks();
    service = new SimpleFINProviderService();

    mockUser = {
      id: "user_1",
      config: {
        simpleFinToken: "https://username:password@bridge.simplefin.org",
        update: vi.fn().mockResolvedValue(true),
      },
    } as unknown as User;

    mockIncrementOrError.mockResolvedValue(undefined);
    global.fetch = vi.fn();

    vi.spyOn(Account, "find").mockResolvedValue([]);
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

    it("should throw NotImplementedException on generateLinkToken", async () => {
      await expect(service.generateLinkToken()).rejects.toThrow(NotImplementedException);
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
      (global.fetch as Mock).mockResolvedValue({
        json: vi.fn().mockResolvedValue(mockJsonResponse),
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
      (global.fetch as Mock).mockResolvedValue({
        ok: false,
        status: 400,
      });

      await expect(service.convertSetupToken(validUrlToken)).rejects.toThrow("Failed to exchange SimpleFIN token.");
    });

    it("should return access token text on successful exchange", async () => {
      const validUrlToken = Buffer.from("https://bridge.simplefin.org/claim").toString("base64");
      (global.fetch as Mock).mockResolvedValue({
        ok: true,
        text: vi.fn().mockResolvedValue("generated-access-token-string"),
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
    it("should return empty array if user has no simpleFinToken", async () => {
      const emptyUser = { config: {} } as User;
      expect(await service.getUnlinkedAccounts(emptyUser)).toEqual([]);
    });

    it("should fetch remote accounts and filter out those that already exist locally", async () => {
      vi.spyOn(Account, "find").mockResolvedValue([{ id: "acc_1", providerAccountId: "acc_1" } as any]);

      vi.spyOn(service as any, "fetchData").mockResolvedValue({
        accounts: [
          { id: "acc_1", name: "Old", balance: "0", "available-balance": "0", currency: "USD", org: { name: "Bank", url: "url" } },
          { id: "acc_2", name: "New", balance: "100", "available-balance": "100", currency: "USD", org: { name: "Bank", url: "url" } },
        ],
      });

      const unlinked = await service.getUnlinkedAccounts(mockUser);

      expect(unlinked).toHaveLength(1);
      expect(unlinked[0]?.id).toBe("acc_2");
    });
  });

  describe("performExchange & performSync", () => {
    it("should throw BadRequestException in performExchange if token missing", async () => {
      const noTokenUser = { config: {} } as User;
      await expect((service as any).performExchange(noTokenUser, [])).rejects.toThrow(BadRequestException);
    });

    it("should performExchange grouping by institution name", async () => {
      vi.spyOn(service as any, "fetchData").mockResolvedValue({
        accounts: [
          { id: "acc_1", name: "Chase Checking", org: { name: "Chase", url: "chase.com" } },
          { id: "acc_2", name: "Chase Savings", org: { name: "Chase", url: "chase.com" } },
          { id: "acc_3", name: "Citi Card", org: { name: "Citi", url: "citi.com" } },
        ],
      });

      const result = await (service as any).performExchange(mockUser, ["acc_1", "acc_2", "acc_3"]);

      expect(result).toHaveLength(2);
      const chaseGroup = result.find((r: any) => r.institutionName === "Chase");
      expect(chaseGroup.rawAccounts).toHaveLength(2);
    });

    it("should fall back to configured provider URL when institution URL is absent", async () => {
      vi.spyOn(service as any, "fetchData").mockResolvedValue({
        accounts: [{ id: "acc-no-url", name: "Account", org: { name: "NoUrl" } }],
      });

      const result = await (service as any).performExchange(mockUser, ["acc-no-url"]);

      expect(result[0].institutionUrl).toBe(service.config.url);
    });

    it("should return empty array in performSync if simpleFinToken is missing", async () => {
      const noTokenUser = { config: {} } as User;
      const res = await (service as any).performSync(noTokenUser, undefined, false);
      expect(res).toEqual([]);
    });

    it("should performSync for existing user accounts with accountsOnly true and false", async () => {
      const existingAccount = {
        id: "acc_1",
        providerAccountId: "acc_1",
        balance: 0,
        availableBalance: 0,
        extra: {},
        institution: { name: "Bank" },
      };
      vi.spyOn(Account, "find").mockResolvedValue([existingAccount as any]);

      vi.spyOn(service as any, "fetchData").mockResolvedValue({
        accounts: [{ id: "acc_1", name: "Bank Acc", balance: "100", "available-balance": "100", currency: "USD", org: { name: "Bank", url: "url" } }],
        errors: ["Bank"],
      });

      const resultsAccountsOnly = await (service as any).performSync(mockUser, undefined, true);
      expect(resultsAccountsOnly).toHaveLength(1);
      expect(resultsAccountsOnly[0].account.balance).toBe(100);

      const resultsFull = await (service as any).performSync(mockUser, undefined, false);
      expect(resultsFull).toHaveLength(1);
      expect(resultsFull[0].account.balance).toBe(100);
    });

    it("should skip provider accounts that are not linked locally", async () => {
      vi.spyOn(Account, "find").mockResolvedValue([]);
      vi.spyOn(service as any, "fetchData").mockResolvedValue({ accounts: [{ id: "unlinked", org: { name: "Bank", url: "url" } }] });

      await expect((service as any).performSync(mockUser, undefined, false)).resolves.toEqual([]);
    });

    it("should create an institution when linked account has none and errors are absent", async () => {
      const existingAccount = { id: "acc-no-institution", providerAccountId: "acc-no-institution", balance: 0, availableBalance: 0, extra: {}, institution: undefined };
      vi.spyOn(Account, "find").mockResolvedValue([existingAccount as any]);
      vi.spyOn(service as any, "fetchData").mockResolvedValue({
        accounts: [{ id: "acc-no-institution", name: "Account", balance: "10", "available-balance": "10", currency: "USD", org: { name: "Bank", url: "url" } }],
      });
      const mapSpy = vi.spyOn(service as any, "mapToSproutAccount");

      await expect((service as any).performSync(mockUser, undefined, true)).resolves.toHaveLength(1);
      expect(mapSpy).toHaveBeenCalledWith(expect.anything(), mockUser.config.simpleFinToken, mockUser, expect.any(Institution));
    });
  });

  describe("mapToSproutAccount & fetchInitialSyncData", () => {
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

      expect(result).toBeTruthy();
      expect(result.balance).toBe(50);
    });

    it("should extract holdings and transactions from the raw payload", async () => {
      const rawAccount = {
        holdings: [{ symbol: "AAPL", shares: "10", market_value: "1500", cost_basis: "1000", purchase_price: "100", currency: "USD", description: "Apple" }],
        transactions: [{ id: "tx_1", amount: "-10", posted: 1715900000, description: "Coffee", extra: { category: "Food" }, pending: false }],
      };
      const mockAccount = { id: "acc_1" } as Account;

      vi.spyOn(Category, "getOrCreate").mockResolvedValue({ id: "cat_food" } as any);

      const result = await (service as any).fetchInitialSyncData(rawAccount, mockAccount, "auth", mockUser);

      expect(result.holdings).toHaveLength(1);
      expect(result.transactions).toHaveLength(1);
    });

    it("should expose account extraction hooks and provider assets", async () => {
      const raw = { id: "raw-id", name: "Raw Name" };
      expect((service as any).extractProviderAccountId(raw)).toBe("raw-id");
      expect((service as any).extractAccountName(raw)).toBe("Raw Name");
      await expect((service as any).getInstitutionAssetsForUser()).resolves.toEqual([undefined]);
    });

    it("should support missing optional balances, holdings, and pending values", async () => {
      const rawAccount = {
        id: "minimal",
        name: "Minimal",
        balance: "1",
        "available-balance": "1",
        currency: "USD",
        transactions: [{ id: "t", amount: "-1", posted: 1, description: "Test" }],
      };
      const result = await (service as any).fetchInitialSyncData(rawAccount, { id: "account" }, "auth", mockUser);

      expect(result.holdings).toBeUndefined();
      expect(result.transactions[0].pending).toBe(false);
    });

    it("should fetch data using encoded SimpleFIN credentials and balance mode", async () => {
      const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValue({
        json: vi.fn().mockResolvedValue({ accounts: [] }),
      } as any);

      await (service as any).fetchData("https://user:pass@example.com", true, mockUser);

      expect(fetchMock).toHaveBeenCalledWith(expect.stringContaining("balances-only=1"), expect.any(Object));
    });
  });
});
