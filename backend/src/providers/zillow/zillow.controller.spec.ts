import { setupTests } from "@backend/test/helpers";
setupTests();

import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { Institution } from "@backend/institution/model/institution.model";
import { ZillowProviderController } from "@backend/providers/zillow/zillow.controller";
import { ZillowProviderService } from "@backend/providers/zillow/zillow.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TestEntities } from "@backend/test/entities";
import { BadRequestException, InternalServerErrorException } from "@nestjs/common";

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

      zillowService.exchangeAndCreateAccounts = jest.fn().mockResolvedValue([{ account: TestEntities.account }]);
      jest.spyOn(AccountHistory, "insertForNewAccount").mockResolvedValue({} as any);

      const res = await controller.link(user, { address: "123 Main St", city: "City", state: "ST", zip: 12345 });

      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res).toBeDefined();
    });
  });
});
