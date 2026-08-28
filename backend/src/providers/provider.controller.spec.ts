import { setupTests } from "@backend/test/helpers";
setupTests();

import { Sync } from "@backend/providers/model/sync.model";
import { BaseProviderController } from "@backend/providers/provider.controller";
import { ProviderService } from "@backend/providers/provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TestEntities } from "@backend/test/entities";
import { InternalServerErrorException } from "@nestjs/common";

describe("BaseProviderController", () => {
  let controller: BaseProviderController;
  let sseService: jest.Mocked<SSEService>;
  let providerService: jest.Mocked<ProviderService>;
  let mockProviders: any[];
  const user = TestEntities.user;

  beforeEach(() => {
    sseService = {
      sendToUser: jest.fn(),
    } as any;

    providerService = {
      syncUserProviders: jest.fn(),
    } as any;

    mockProviders = [
      {
        config: { dbType: "plaid", name: "Plaid", enabled: true },
        getAppConfiguration: jest.fn().mockReturnValue({ enabled: true }),
        isAvailable: jest.fn().mockResolvedValue(true),
      },
      {
        config: { dbType: "disabled_provider", name: "Disabled", enabled: false },
        getAppConfiguration: jest.fn().mockReturnValue({ enabled: false }),
        isAvailable: jest.fn().mockResolvedValue(false),
      },
    ];

    controller = new BaseProviderController(sseService, providerService, mockProviders);
  });

  describe("getConfig", () => {
    it("should filter enabled providers and map availability", async () => {
      const config = await controller.getConfig(user);

      expect(config.length).toBe(1);
      expect(config[0]!.dbType).toBe("plaid");
      expect(config[0]!.enabled).toBe(true);
    });
  });

  describe("manualSync", () => {
    it("should throw InternalServerErrorException if a sync is already running and force is false", async () => {
      jest.spyOn(Sync, "findOne").mockResolvedValue(TestEntities.sync);

      await expect(controller.manualSync(user, { force: false })).rejects.toThrow(InternalServerErrorException);
    });

    it("should proceed with sync if a sync is running but force is true", async () => {
      jest.spyOn(Sync, "findOne").mockResolvedValue(TestEntities.sync);
      const syncResult = TestEntities.sync;
      providerService.syncUserProviders.mockResolvedValue([syncResult] as any);

      await controller.manualSync(user, { force: true });

      expect(providerService.syncUserProviders).toHaveBeenCalledWith(user, false);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.SYNC);
    });

    it("should sync all providers if providers list is empty or omitted", async () => {
      jest.spyOn(Sync, "findOne").mockResolvedValue(null);
      const syncResult = TestEntities.sync;
      providerService.syncUserProviders.mockResolvedValue([syncResult] as any);

      await controller.manualSync(user, {});

      expect(providerService.syncUserProviders).toHaveBeenCalledWith(user, false);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.SYNC);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
    });

    it("should sync specific requested providers if provided", async () => {
      jest.spyOn(Sync, "findOne").mockResolvedValue(null);
      const syncResult = TestEntities.sync;
      providerService.syncUserProviders.mockResolvedValue(syncResult as any);

      await controller.manualSync(user, { providers: ["plaid" as any] });

      expect(providerService.syncUserProviders).toHaveBeenCalledWith(user, false, "plaid");
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.SYNC);
    });
  });
});
