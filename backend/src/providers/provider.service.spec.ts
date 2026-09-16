import { setupTests } from "@backend/test/helpers";
setupTests();

import { ProviderService } from "@backend/providers/provider.service";
import { ProviderType } from "@backend/providers/base/provider.type";
import { SyncTriggerType } from "@backend/providers/model/sync.type";
import { ProviderSyncJob } from "@backend/providers/jobs/sync";
import { TestEntities } from "@backend/test/entities";
import { NotFoundException } from "@nestjs/common";

describe("ProviderService", () => {
  let service: ProviderService;
  let discoveryService: any;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();

    discoveryService = {
      getProviders: jest.fn(),
    };

    service = new ProviderService(discoveryService);
  });

  describe("syncUserProviders", () => {
    it("should throw NotFoundException if specific providerType job runner is not found", async () => {
      discoveryService.getProviders.mockReturnValue([]);

      await expect(service.syncUserProviders(user, SyncTriggerType.MANUAL, ProviderType.plaid)).rejects.toThrow(NotFoundException);
    });

    it("should execute specific target provider sync task when requested", async () => {
      const mockJob = Object.create(ProviderSyncJob.prototype);
      mockJob.provider = { config: { dbType: ProviderType.plaid } };
      mockJob.processTask = jest.fn().mockResolvedValue(TestEntities.sync);

      discoveryService.getProviders.mockReturnValue([{ instance: mockJob }]);

      const res = await service.syncUserProviders(user, SyncTriggerType.MANUAL, ProviderType.plaid);

      expect(mockJob.processTask).toHaveBeenCalledWith({ userId: user.id, triggerType: SyncTriggerType.MANUAL });
      expect(res).toEqual(TestEntities.sync);
    });

    it("should execute all active sync jobs if providerType is omitted", async () => {
      const mockJob1 = Object.create(ProviderSyncJob.prototype);
      mockJob1.provider = { config: { dbType: ProviderType.plaid } };
      mockJob1.processTask = jest.fn().mockResolvedValue(TestEntities.sync);

      discoveryService.getProviders.mockReturnValue([{ instance: mockJob1 }]);

      const res = await service.syncUserProviders(user, SyncTriggerType.SCHEDULED);

      expect(mockJob1.processTask).toHaveBeenCalledWith({ userId: user.id, triggerType: SyncTriggerType.SCHEDULED });
      expect(res).toEqual([TestEntities.sync]);
    });
  });
});
