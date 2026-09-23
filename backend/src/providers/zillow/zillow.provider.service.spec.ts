import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Account } from "@backend/account/model/account.model.js";
import { ProviderRateLimit } from "@backend/providers/base/rate-limit.js";
import { ProviderType } from "@backend/providers/base/provider.type.js";
import { ZillowPropertyDTO } from "@backend/providers/zillow/model/api/zillow.lookup.dto.js";
import { ZillowProviderService } from "@backend/providers/zillow/zillow.provider.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { User } from "@backend/user/model/user.model.js";
import { BadRequestException, NotImplementedException } from "@nestjs/common";

describe("ZillowProviderService", () => {
  let service: ZillowProviderService;
  let user: User;

  beforeEach(() => {
    vi.restoreAllMocks();
    user = TestEntities.user;

    vi.spyOn(ProviderRateLimit.prototype, "incrementOrError").mockResolvedValue(undefined);

    service = new ZillowProviderService();
  });

  describe("isAvailable & generateLinkToken", () => {
    it("should expose Zillow configuration and rate limit", () => {
      expect(service.getAppConfiguration()).toBeDefined();
      expect(service.rateLimit(user)).toBeInstanceOf(ProviderRateLimit);
    });

    it("should return true for isAvailable", async () => {
      expect(await service.isAvailable(user)).toBe(true);
    });

    it("should throw NotImplementedException for generateLinkToken and performSync", async () => {
      await expect(service.generateLinkToken()).rejects.toThrow(NotImplementedException);
      await expect((service as unknown as { performSync: () => Promise<unknown> }).performSync()).rejects.toThrow(NotImplementedException);
    });
  });

  describe("get", () => {
    it("should fetch zillow info for accounts, update balances, and skip accounts with missing zpid", async () => {
      const zillowAcc1 = TestEntities.account;
      zillowAcc1.provider = ProviderType.zillow;
      zillowAcc1.providerAccountId = "123456";

      const zillowAccNoZpid = TestEntities.account;
      zillowAccNoZpid.provider = ProviderType.zillow;
      zillowAccNoZpid.providerAccountId = "";

      vi.spyOn(Account, "find").mockResolvedValue([zillowAcc1, zillowAccNoZpid]);
      vi.spyOn(service, "getInfoByZpid").mockResolvedValue({
        zpid: "123456",
        zestimate: 600000,
        rentZestimate: 3000,
        currency: "USD",
      } as any);

      const results = await service.get(user, false, 0 as any);
      expect(results.length).toBe(1);
      expect(zillowAcc1.balance).toBe(600000);
    });

    it("should catch errors per account in get loop", async () => {
      const zillowAcc1 = TestEntities.account;
      zillowAcc1.provider = ProviderType.zillow;
      zillowAcc1.providerAccountId = "123456";

      vi.spyOn(Account, "find").mockResolvedValue([zillowAcc1]);
      vi.spyOn(service, "getInfoByZpid").mockRejectedValue(new Error("Zillow scrape error"));

      const results = await service.get(user, false, 0 as any);
      expect(results).toEqual([]);
    });
  });

  describe("getInfoByAddress, getInfoByZpid, and resultFromContent", () => {
    it("should fetch page content and parse property info", async () => {
      (service as unknown as { impit: { fetch: () => Promise<unknown> } }).impit.fetch = vi.fn().mockResolvedValue({
        text: vi.fn().mockResolvedValue("normal zillow html content"),
      });

      const parsedRes = { zpid: "123456", zestimate: 500000, rentZestimate: 2500, currency: "USD" };
      vi.spyOn(service as unknown as { resultFromContent: () => unknown }, "resultFromContent").mockReturnValue(parsedRes);

      const res = await service.getInfoByZpid(user, "123456");
      expect(res.zpid).toBe("123456");

      const resAddr = await service.getInfoByAddress(user, "123 Main St", "Seattle", "WA", 98101);
      expect(resAddr.zestimate).toBe(500000);
    });

    it("should test resultFromContent parsing and error checks", () => {
      const htmlContent = `
        "zpid":111111
        "zpid":222222
        Zestimate $500,000
        Rent Zestimate $2,500
        "priceCurrency":"USD"
      `;

      const result = (service as unknown as { resultFromContent: (c: string) => { zpid: string; zestimate: number; currency: string } }).resultFromContent(
        htmlContent,
      );
      expect(result.zpid).toBe("222222");
      expect(result.zestimate).toBe(500000);
      expect(result.currency).toBe("USD");
    });

    it("should throw error if getByUrl detects rate limits or captcha", async () => {
      (service as unknown as { impit: { fetch: () => Promise<unknown> } }).impit.fetch = vi.fn().mockResolvedValue({
        text: vi.fn().mockResolvedValue("px-captcha Access to this page has been denied"),
      });

      await expect((service as unknown as { getByUrl: (u: string) => Promise<string> }).getByUrl("https://zillow.com")).rejects.toThrow(
        "Provider temporarily unavailable due to rate limits.",
      );
    });

    it("should throw BadRequestException if property cannot be parsed", () => {
      expect(() => (service as unknown as { resultFromContent: (c: string) => unknown }).resultFromContent("empty html")).toThrow(BadRequestException);
    });
  });

  describe("performExchange and helper hooks", () => {
    it("should performExchange for valid property payload and mapToSproutAccount", async () => {
      vi.spyOn(service, "getInfoByAddress").mockResolvedValue({
        zpid: "123456",
        zestimate: 500000,
        rentZestimate: 2500,
        currency: "",
      } as any);

      const payload = new ZillowPropertyDTO();
      payload.address = "123 Main St";
      payload.city = "Seattle";
      payload.state = "WA";
      payload.zip = 98101;

      const res = await service.performExchange(user, payload);
      expect(res.length).toBe(1);
      expect(res[0]?.institutionName).toBe("Zillow");

      const mappedAcc = await (service as unknown as { mapToSproutAccount: (r: unknown, a: void, u: User, i: unknown) => Promise<Account> }).mapToSproutAccount(
        res[0]!.rawAccounts[0]!,
        undefined,
        user,
        TestEntities.institution,
      );
      expect(mappedAcc.currency).toBe("USD");
    });

    it("should throw BadRequestException in performExchange if zpid or zestimate missing", async () => {
      vi.spyOn(service, "getInfoByAddress").mockResolvedValue({
        zpid: "",
        zestimate: null,
      } as any);

      const payload = new ZillowPropertyDTO();
      payload.address = "123 Main St";
      payload.city = "Seattle";
      payload.state = "WA";
      payload.zip = 98101;

      await expect(service.performExchange(user, payload)).rejects.toThrow(BadRequestException);
    });

    it("should test helper hooks", async () => {
      const rawPayload = { result: { zpid: "12345" } as any, address: "123 Main St" };
      expect((service as unknown as { extractProviderAccountId: (r: unknown) => string }).extractProviderAccountId(rawPayload)).toBe("12345");
      expect((service as unknown as { extractAccountName: (r: unknown) => string }).extractAccountName(rawPayload)).toBe("123 Main St");
      expect(await (service as unknown as { getInstitutionAssetsForUser: () => Promise<undefined[]> }).getInstitutionAssetsForUser()).toEqual([]);
    });
  });
});
