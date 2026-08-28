import { setupTests } from "@backend/test/helpers";
setupTests();

import { ZillowProviderController } from "@backend/providers/zillow/zillow.controller";
import { ZillowProviderService } from "@backend/providers/zillow/zillow.provider.service";
import { SSEService } from "@backend/sse/sse.service";
import { TestEntities } from "@backend/test/entities";
import { ZillowAsset } from "@backend/providers/zillow/model/zillow.asset";
import { Institution } from "@backend/institution/model/institution.model";
import { Account } from "@backend/account/model/account.model";
import { AccountHistory } from "@backend/account/model/account.history.model";
import { BadRequestException, InternalServerErrorException } from "@nestjs/common";
import { SSEEventType } from "@backend/sse/model/event.model";

describe("ZillowProviderController", () => {
  let controller: ZillowProviderController;
  let zillowService: jest.Mocked<ZillowProviderService>;
  let sseService: jest.Mocked<SSEService>;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();

    zillowService = {
      config: { url: "https://zillow.com" },
      getInfoByAddress: jest.fn(),
    } as any;

    sseService = {
      sendToUser: jest.fn(),
    } as any;

    controller = new ZillowProviderController(sseService, zillowService);
  });

  describe("getByAccount", () => {
    it("should return ZillowAsset for account", async () => {
      const mockAsset = { id: "asset-1", zpid: 12345 };
      jest.spyOn(ZillowAsset, "findOne").mockResolvedValue(mockAsset as any);

      const res = await controller.getByAccount(user, "acc-1");

      expect(ZillowAsset.findOne).toHaveBeenCalledWith({
        where: { account: { id: "acc-1", user: { id: user.id } } },
      });
      expect(res).toBe(mockAsset);
    });
  });

  describe("lookupProperty", () => {
    it("should return info by address from zillow service", async () => {
      const info = { zpid: 12345, zestimate: 500000 };
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

    it("should create institution, account, asset, history and trigger force update", async () => {
      zillowService.getInfoByAddress.mockResolvedValue({ zpid: 999, zestimate: 450000 } as any);
      jest.spyOn(Institution, "findOne").mockResolvedValue(TestEntities.institution);

      const newAcc = TestEntities.account;
      newAcc.insert = jest.fn().mockResolvedValue(newAcc);
      jest.spyOn(Account.prototype, "insert").mockResolvedValue(newAcc);

      const mockAsset = { insert: jest.fn().mockResolvedValue({}) };
      jest.spyOn(ZillowAsset.prototype, "insert").mockResolvedValue(mockAsset as any);
      jest.spyOn(AccountHistory, "insertForNewAccount").mockResolvedValue({} as any);

      const res = await controller.link(user, { address: "123 Main St", city: "City", state: "ST", zip: 12345 });

      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res).toBeDefined();
    });
  });
});
