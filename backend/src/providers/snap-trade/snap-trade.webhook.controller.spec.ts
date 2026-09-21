import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Configuration } from "@backend/config/core.js";
import { ProviderSyncService } from "@backend/providers/base/sync.service.js";
import { SnapTradeInstitutionAsset } from "@backend/providers/snap-trade/model/snap-trade.institution.asset.model.js";
import { SnapTradeProviderService } from "@backend/providers/snap-trade/snap-trade.provider.service.js";
import { SnapTradeWebHookController } from "@backend/providers/snap-trade/snap-trade.webhook.controller.js";
import { TestEntities } from "@backend/test/entities.js";
import { BadRequestException, UnauthorizedException } from "@nestjs/common";
import crypto from "crypto";

describe("SnapTradeWebHookController", () => {
  let controller: SnapTradeWebHookController;
  let snapTradeProvider: Mocked<SnapTradeProviderService>;
  let providerSyncService: Mocked<ProviderSyncService>;

  beforeEach(() => {
    vi.restoreAllMocks();
    snapTradeProvider = {} as any;
    providerSyncService = {
      syncForProvider: vi.fn().mockResolvedValue(undefined),
      flagInstitution: vi.fn().mockResolvedValue(undefined),
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
      vi.spyOn(controller as any, "verifyWebhookSignature").mockReturnValue(false);

      await expect(controller.handleSnapTradeWebhook(headers, req, {})).rejects.toThrow(UnauthorizedException);
    });

    it("should process webhook and return received status on valid signature", async () => {
      const headers = { signature: "sig" };
      const req: any = { rawBody: Buffer.from("body") };
      vi.spyOn(controller as any, "verifyWebhookSignature").mockReturnValue(true);
      const handleWebhookSpy = vi.spyOn(controller as any, "handleWebhook").mockImplementation(() => Promise.resolve());

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
      vi.spyOn(SnapTradeInstitutionAsset, "findOne").mockResolvedValue(mockAsset as any);

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
      vi.spyOn(SnapTradeInstitutionAsset, "findOne").mockResolvedValue(mockAsset as any);

      await (controller as any).handleWebhook({
        eventType: "CONNECTION_BROKEN",
        brokerageAuthorizationId: "auth-123",
      });

      expect(SnapTradeInstitutionAsset.findOne).toHaveBeenCalled();
      expect(providerSyncService.flagInstitution).toHaveBeenCalledWith(mockAsset.institution, true);
    });

    it("should handle unknown eventType by logging and ignoring", async () => {
      const user = TestEntities.user;
      const mockAsset = {
        user,
        institution: { ...TestEntities.institution, user },
      };
      vi.spyOn(SnapTradeInstitutionAsset, "findOne").mockResolvedValue(mockAsset as any);

      await (controller as any).handleWebhook({
        eventType: "UNKNOWN_EVENT",
        brokerageAuthorizationId: "auth-123",
      });

      expect(providerSyncService.syncForProvider).not.toHaveBeenCalled();
      expect(providerSyncService.flagInstitution).not.toHaveBeenCalled();
    });

    it("should handle exceptions in handleWebhook gracefully", async () => {
      vi.spyOn(SnapTradeInstitutionAsset, "findOne").mockRejectedValue(new Error("DB error"));

      await expect(
        (controller as any).handleWebhook({
          eventType: "TRANSACTIONS_SYNC_COMPLETED",
          brokerageAuthorizationId: "auth-123",
        }),
      ).resolves.not.toThrow();
    });
  });

  describe("verifyWebhookSignature", () => {
    it("should return false if consumerKey is missing", () => {
      Configuration.providers.snapTrade.consumerKey = "";
      const res = (controller as any).verifyWebhookSignature("body", "sig");
      expect(res).toBe(false);
    });

    it("should calculate HMAC SHA256 and verify signature", () => {
      const consumerKey = "test-secret-key";
      Configuration.providers.snapTrade.consumerKey = consumerKey;

      const body = "raw-payload-body";
      const hmac = crypto.createHmac("sha256", consumerKey).update(body).digest("base64");

      const verifyFn = (controller as any).verifyWebhookSignature.bind(controller);
      expect(verifyFn(body, hmac)).toBe(true);
      expect(verifyFn(body, "invalid-hmac-signature")).toBe(false);
    });
  });
});
