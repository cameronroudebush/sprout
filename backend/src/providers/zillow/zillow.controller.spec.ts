import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { AccountHistory } from "@backend/account/model/account.history.model.js";
import { Account } from "@backend/account/model/account.model.js";
import { Institution } from "@backend/institution/model/institution.model.js";
import { ProviderType } from "@backend/providers/base/provider.type.js";
import { ZillowProviderController } from "@backend/providers/zillow/zillow.controller.js";
import { ZillowProviderService } from "@backend/providers/zillow/zillow.provider.service.js";
import { SSEEventType } from "@backend/sse/model/event.model.js";
import { SSEService } from "@backend/sse/sse.service.js";
import { TestEntities } from "@backend/test/entities.js";
import { BadRequestException, InternalServerErrorException } from "@nestjs/common";

describe("ZillowProviderController", () => {
  let controller: ZillowProviderController;
  let zillowService: Mocked<ZillowProviderService>;
  let sseService: Mocked<SSEService>;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.clearAllMocks();

    zillowService = {
      config: { url: "https://zillow.com" },
      getInfoByAddress: vi.fn(),
      exchangeAndCreateAccounts: vi.fn(),
    } as unknown as Mocked<ZillowProviderService>;

    sseService = {
      sendToUser: vi.fn(),
    } as unknown as Mocked<SSEService>;

    controller = new ZillowProviderController(sseService, zillowService);
  });

  describe("getByAccount", () => {
    it("should return providerAccountId if account is valid Zillow account", async () => {
      const zillowAcc = TestEntities.account;
      zillowAcc.provider = ProviderType.zillow;
      zillowAcc.providerAccountId = "zpid-12345";
      vi.spyOn(Account, "findOne").mockResolvedValue(zillowAcc);

      const zpid = await controller.getByAccount(user, zillowAcc.id);
      expect(zpid).toBe("zpid-12345");
    });

    it("should throw BadRequestException if account is missing or not zillow", async () => {
      vi.spyOn(Account, "findOne").mockResolvedValue(null);

      await expect(controller.getByAccount(user, "invalid-acc")).rejects.toThrow(BadRequestException);
    });
  });

  describe("lookupProperty", () => {
    it("should return info by address from zillow service", async () => {
      const info = { zpid: "12345", zestimate: 500000 };
      zillowService.getInfoByAddress.mockResolvedValue(info as any);

      const res = await controller.lookupProperty(user, {
        address: "123 Main St",
        city: "Seattle",
        state: "WA",
        zip: 98101,
      });

      expect(zillowService.getInfoByAddress).toHaveBeenCalledWith(user, "123 Main St", "Seattle", "WA", 98101);
      expect(res).toBe(info);
    });

    it("should throw InternalServerErrorException on error", async () => {
      zillowService.getInfoByAddress.mockRejectedValue(new Error("Zillow error"));

      await expect(controller.lookupProperty(user, { address: "123 Main St", city: "City", state: "ST", zip: 12345 })).rejects.toThrow(
        InternalServerErrorException,
      );
    });
  });

  describe("link", () => {
    it("should throw BadRequestException if zpid or zestimate missing", async () => {
      zillowService.getInfoByAddress.mockResolvedValue({ zpid: null, zestimate: null } as any);

      await expect(controller.link(user, { address: "123 Main St", city: "City", state: "ST", zip: 12345 })).rejects.toThrow(BadRequestException);
    });

    it("should throw InternalServerErrorException if createdAccount is missing", async () => {
      zillowService.getInfoByAddress.mockResolvedValue({ zpid: "999", zestimate: 450000 } as any);
      zillowService.exchangeAndCreateAccounts.mockResolvedValue([]);

      await expect(controller.link(user, { address: "123 Main St", city: "City", state: "ST", zip: 12345 })).rejects.toThrow(InternalServerErrorException);
    });

    it("should create institution, account, asset, history and trigger force update", async () => {
      zillowService.getInfoByAddress.mockResolvedValue({ zpid: "999", zestimate: 450000 } as any);
      vi.spyOn(Institution, "findOne").mockResolvedValue(TestEntities.institution);

      const newAcc = TestEntities.account;
      newAcc.insert = vi.fn().mockResolvedValue(newAcc);
      vi.spyOn(Account.prototype, "insert").mockResolvedValue(newAcc);

      zillowService.exchangeAndCreateAccounts.mockResolvedValue([{ account: TestEntities.account }]);
      vi.spyOn(AccountHistory, "insertForNewAccount").mockResolvedValue({} as any);

      const res = await controller.link(user, { address: "123 Main St", city: "City", state: "ST", zip: 12345 });

      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res).toBeDefined();
    });
  });
});
