import { setupTests } from "@backend/test/helpers";
setupTests();

import { ProviderSyncService } from "@backend/providers/base/sync.service";
import { SnapTradeInstitutionAsset } from "@backend/providers/snap-trade/model/snap-trade.institution.asset.model";
import { SnapTradeProviderService } from "@backend/providers/snap-trade/snap-trade.provider.service";
import { SnapTradeWebHookController } from "@backend/providers/snap-trade/snap-trade.webhook.controller";
import { TestEntities } from "@backend/test/entities";
import { BadRequestException, UnauthorizedException } from "@nestjs/common";

describe("SnapTradeWebHookController", () => {
  let controller: SnapTradeWebHookController;
  let snapTradeProvider: jest.Mocked<SnapTradeProviderService>;
  let providerSyncService: jest.Mocked<ProviderSyncService>;

  beforeEach(() => {
    snapTradeProvider = {} as any;
    providerSyncService = {
      syncForProvider: jest.fn().mockResolvedValue(undefined),
      flagInstitution: jest.fn().mockResolvedValue(undefined),
    } as any;

    controller = new SnapTradeWebHookController(snapTradeProvider, providerSyncService);
  });

  describe("handleSnapTradeWebhook", () => {
    it("should throw BadRequestException if signature header missing", async () => {
      const headers = {};
      const req: any = { rawBody: Buffer.from("body") };

      await expect(controller.handleSnapTradeWebhook(headers, req, {})).rejects.toThrow(BadRequestException);
    });

    it("should throw BadRequestException if rawBody missing", async () => {
      const headers = { signature: "sig" };
      const req: any = {};

      await expect(controller.handleSnapTradeWebhook(headers, req, {})).rejects.toThrow(BadRequestException);
    });

    it("should throw UnauthorizedException if signature verification fails", async () => {
      const headers = { signature: "sig" };
      const req: any = { rawBody: Buffer.from("body") };
      jest.spyOn(controller as any, "verifyWebhookSignature").mockReturnValue(false);

      await expect(controller.handleSnapTradeWebhook(headers, req, {})).rejects.toThrow(UnauthorizedException);
    });

    it("should process webhook and return received status on valid signature", async () => {
      const headers = { signature: "sig" };
      const req: any = { rawBody: Buffer.from("body") };
      jest.spyOn(controller as any, "verifyWebhookSignature").mockReturnValue(true);
      const handleWebhookSpy = jest.spyOn(controller as any, "handleWebhook").mockImplementation(() => Promise.resolve());

      const res = await controller.handleSnapTradeWebhook(headers, req, { eventType: "CONNECTION_ADDED" });

      expect(res).toEqual({ status: "received" });
      expect(handleWebhookSpy).toHaveBeenCalledWith({ eventType: "CONNECTION_ADDED" });
    });
  });

  describe("handleWebhook internal logic", () => {
    it("should log warning and return early if brokerageAuthorizationId is missing", async () => {
      await (controller as any).handleWebhook({ eventType: "CONNECTION_ADDED" });

      expect(providerSyncService.syncForProvider).not.toHaveBeenCalled();
    });

    it("should trigger syncForProvider on TRANSACTIONS_SYNC_COMPLETED", async () => {
      const user = TestEntities.user;
      const mockAsset = {
        user,
        institution: { ...TestEntities.institution, user },
      };
      jest.spyOn(SnapTradeInstitutionAsset, "findOne").mockResolvedValue(mockAsset as any);

      await (controller as any).handleWebhook({
        eventType: "TRANSACTIONS_SYNC_COMPLETED",
        brokerageAuthorizationId: "auth-123",
      });

      expect(SnapTradeInstitutionAsset.findOne).toHaveBeenCalled();
      expect(providerSyncService.syncForProvider).toHaveBeenCalled();
    });

    it("should flag institution broken on CONNECTION_BROKEN", async () => {
      const user = TestEntities.user;
      const mockAsset = {
        user,
        institution: { ...TestEntities.institution, user },
      };
      jest.spyOn(SnapTradeInstitutionAsset, "findOne").mockResolvedValue(mockAsset as any);

      await (controller as any).handleWebhook({
        eventType: "CONNECTION_BROKEN",
        brokerageAuthorizationId: "auth-123",
      });

      expect(SnapTradeInstitutionAsset.findOne).toHaveBeenCalled();
      expect(providerSyncService.flagInstitution).toHaveBeenCalledWith(mockAsset.institution, true);
    });

    it("should return early if SnapTradeInstitutionAsset is not found", async () => {
      jest.spyOn(SnapTradeInstitutionAsset, "findOne").mockResolvedValue(null);

      await (controller as any).handleWebhook({
        eventType: "TRANSACTIONS_SYNC_COMPLETED",
        brokerageAuthorizationId: "non-existent-auth",
      });

      expect(providerSyncService.syncForProvider).not.toHaveBeenCalled();
      expect(providerSyncService.flagInstitution).not.toHaveBeenCalled();
    });
  });
});
