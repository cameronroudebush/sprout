import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { Institution } from "@backend/institution/model/institution.model";
import { ZillowAsset } from "@backend/providers/zillow/model/zillow.asset";
import { ZillowProviderController } from "@backend/providers/zillow/zillow.controller";
import { ZillowProviderService } from "@backend/providers/zillow/zillow.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, InternalServerErrorException } from "@nestjs/common";
import { Test, TestingModule } from "@nestjs/testing";

describe("ZillowProviderController", () => {
  let controller: ZillowProviderController;
  let zillowProviderService: ZillowProviderService;
  let sseService: SSEService;

  const mockUser = { id: "user-123" } as User;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ZillowProviderController],
      providers: [
        {
          provide: ZillowProviderService,
          useValue: {
            config: { url: "https://zillow.com" },
            getInfoByAddress: jest.fn(),
          },
        },
        {
          provide: SSEService,
          useValue: {
            sendToUser: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<ZillowProviderController>(ZillowProviderController);
    zillowProviderService = module.get<ZillowProviderService>(ZillowProviderService);
    sseService = module.get<SSEService>(SSEService);

    // Mocks for DB entities
    ZillowAsset.findOne = jest.fn();
    ZillowAsset.prototype.insert = jest.fn().mockImplementation(function (this: ZillowAsset) {
      return Promise.resolve(this);
    });
    Institution.findOne = jest.fn();
    Account.prototype.insert = jest.fn().mockImplementation(function (this: Account) {
      return Promise.resolve(this);
    });
    AccountHistory.insertForNewAccount = jest.fn();
  });

  describe("getByAccount", () => {
    it("should return a ZillowAsset matching the provided accountId", async () => {
      const mockAsset = { id: "asset-1" };
      (ZillowAsset.findOne as jest.Mock).mockResolvedValue(mockAsset);

      const result = await controller.getByAccount(mockUser, "acc-1");

      expect(result).toEqual(mockAsset);
      expect(ZillowAsset.findOne).toHaveBeenCalledWith({ where: { account: { id: "acc-1", user: { id: mockUser.id } } } });
    });
  });

  describe("lookupProperty", () => {
    it("should return property info given valid address data", async () => {
      const dto = { address: "123 Main St", city: "Anytown", state: "NY", zip: "12345" } as any;
      const expectedData = { zpid: "zpid123", zestimate: 500000 };

      (zillowProviderService.getInfoByAddress as jest.Mock).mockResolvedValue(expectedData);

      const result = await controller.lookupProperty(mockUser, dto);

      expect(result).toEqual(expectedData);
      expect(zillowProviderService.getInfoByAddress).toHaveBeenCalledWith(mockUser, "123 Main St", "Anytown", "NY", "12345");
    });

    it("should throw InternalServerErrorException if service throws an error", async () => {
      const dto = { address: "123 Main St", city: "Anytown", state: "NY", zip: "12345" } as any;
      (zillowProviderService.getInfoByAddress as jest.Mock).mockRejectedValue(new Error("Zillow Error"));

      await expect(controller.lookupProperty(mockUser, dto)).rejects.toThrow(InternalServerErrorException);
    });
  });

  describe("link", () => {
    it("should create a new tracked account and asset and trigger SSE", async () => {
      const dto = { address: "123 Main St", city: "Anytown", state: "NY", zip: "12345" } as any;
      const propertyInfo = { zpid: "zpid123", zestimate: 500000 };

      (zillowProviderService.getInfoByAddress as jest.Mock).mockResolvedValue(propertyInfo);
      (Institution.findOne as jest.Mock).mockResolvedValue(null);

      const result = await controller.link(mockUser, dto);

      expect(zillowProviderService.getInfoByAddress).toHaveBeenCalledWith(mockUser, "123 Main St", "Anytown", "NY", "12345");
      expect(Institution.findOne).toHaveBeenCalled();
      expect(result.name).toBe("123 Main St");
      expect(result.balance).toBe(500000);
      expect(AccountHistory.insertForNewAccount).toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(mockUser, SSEEventType.FORCE_UPDATE);
    });

    it("should use an existing institution if found", async () => {
      const dto = { address: "123 Main St", city: "Anytown", state: "NY", zip: "12345" } as any;
      const propertyInfo = { zpid: "zpid123", zestimate: 500000 };
      const existingInstitution = { id: "inst-1", name: "Zillow" };

      (zillowProviderService.getInfoByAddress as jest.Mock).mockResolvedValue(propertyInfo);
      (Institution.findOne as jest.Mock).mockResolvedValue(existingInstitution);

      const result = await controller.link(mockUser, dto);

      expect(result.institution).toEqual(existingInstitution);
    });

    it("should throw BadRequestException if zpid is missing", async () => {
      const dto = { address: "123 Main St", city: "Anytown", state: "NY", zip: "12345" } as any;
      const propertyInfo = { zestimate: 500000 }; // Missing zpid

      (zillowProviderService.getInfoByAddress as jest.Mock).mockResolvedValue(propertyInfo);

      await expect(controller.link(mockUser, dto)).rejects.toThrow(BadRequestException);
    });

    it("should throw BadRequestException if zestimate is null", async () => {
      const dto = { address: "123 Main St", city: "Anytown", state: "NY", zip: "12345" } as any;
      const propertyInfo = { zpid: "zpid123", zestimate: null };

      (zillowProviderService.getInfoByAddress as jest.Mock).mockResolvedValue(propertyInfo);

      await expect(controller.link(mockUser, dto)).rejects.toThrow(BadRequestException);
    });
  });
});
