import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { PlaidInstitutionAsset } from "@backend/providers/plaid/model/plaid.institution.asset.js";
import { PlaidWebhookController } from "@backend/providers/plaid/plaid.webhook.controller.js";
import { TestEntities } from "@backend/test/entities.js";
import { BadRequestException, UnauthorizedException } from "@nestjs/common";
import crypto from "crypto";
import jwt from "jsonwebtoken";

describe("PlaidWebhookController", () => {
  let controller: PlaidWebhookController;
  let mockPlaidProvider: any;
  let mockSyncService: any;

  beforeEach(() => {
    vi.clearAllMocks();

    mockPlaidProvider = {
      updateAllItemWebhooks: vi.fn().mockResolvedValue({ successCount: 1, failureCount: 0 }),
      plaidClient: {
        webhookVerificationKeyGet: vi.fn(),
      },
    };

    mockSyncService = {
      syncForProvider: vi.fn().mockResolvedValue(undefined),
      flagInstitution: vi.fn().mockResolvedValue(undefined),
    };

    controller = new PlaidWebhookController(mockPlaidProvider, mockSyncService);
  });

  describe("handlePlaidWebhook", () => {
    it("should throw BadRequestException if signature header or rawBody is missing", async () => {
      const headers: Record<string, string> = {};
      const req: any = { rawBody: Buffer.from("body") };

      await expect(controller.handlePlaidWebhook(headers, req, {} as any)).rejects.toThrow(BadRequestException);

      const headersWithSig = { "plaid-verification": "sig" };
      const reqNoBody: any = { rawBody: null };
      await expect(controller.handlePlaidWebhook(headersWithSig, reqNoBody, {} as any)).rejects.toThrow(BadRequestException);
    });

    it("should throw BadRequestException if signature verification fails", async () => {
      const headers = { "plaid-verification": "invalid-sig" };
      const req: any = { rawBody: Buffer.from("body") };

      vi.spyOn(controller as any, "verifyPlaidWebhook").mockResolvedValue(false);

      await expect(controller.handlePlaidWebhook(headers, req, {} as any)).rejects.toThrow(BadRequestException);
    });

    it("should return received on valid webhook and delegate to handleWebhook", async () => {
      const headers = { "plaid-verification": "valid-sig" };
      const req: any = { rawBody: Buffer.from("body") };

      vi.spyOn(controller as any, "verifyPlaidWebhook").mockResolvedValue(true);
      vi.spyOn(controller as any, "handleWebhook").mockImplementation(async () => {});

      const res = await controller.handlePlaidWebhook(headers, req, {
        webhook_type: "TRANSACTIONS",
        webhook_code: "SYNC_UPDATES_AVAILABLE",
        item_id: "item-123",
      } as any);

      expect(res).toEqual({ status: "received" });
    });

    it("should process handleWebhook for TRANSACTIONS, ITEM, HOLDINGS, and unknown types", async () => {
      const inst = TestEntities.institution;
      inst.user = TestEntities.user;
      const asset = new PlaidInstitutionAsset(inst, "access-123", "item-123");

      vi.spyOn(PlaidInstitutionAsset, "findOne").mockResolvedValue(asset);

      // TRANSACTIONS / SYNC_UPDATES_AVAILABLE
      await (controller as any).handleWebhook({
        webhook_type: "TRANSACTIONS",
        webhook_code: "SYNC_UPDATES_AVAILABLE",
        item_id: "item-123",
      });

      expect(mockSyncService.syncForProvider).toHaveBeenCalled();

      // ITEM / ERROR
      await (controller as any).handleWebhook({
        webhook_type: "ITEM",
        webhook_code: "ERROR",
        item_id: "item-123",
      });

      expect(mockSyncService.flagInstitution).toHaveBeenCalledWith(asset.institution, true);

      // HOLDINGS / DEFAULT_UPDATE
      await (controller as any).handleWebhook({
        webhook_type: "HOLDINGS",
        webhook_code: "DEFAULT_UPDATE",
        item_id: "item-123",
      });

      // Unknown code/type
      await (controller as any).handleWebhook({
        webhook_type: "UNKNOWN",
        webhook_code: "UNKNOWN",
      });
    });

    it("should throw BadRequestException in getPlaidInstitutionAsset if asset missing", async () => {
      vi.spyOn(PlaidInstitutionAsset, "findOne").mockResolvedValue(null);

      await expect((controller as any).getPlaidInstitutionAsset({ item_id: "missing" })).rejects.toThrow(BadRequestException);
      await expect((controller as any).getPlaidInstitutionAsset({})).rejects.toThrow(BadRequestException);
    });

    it("should test verifyPlaidWebhook branches and successful verification", async () => {
      vi.spyOn(jwt, "decode").mockReturnValue(null);
      const res1 = await (controller as any).verifyPlaidWebhook("body", "jwt");
      expect(res1).toBe(false);

      vi.spyOn(jwt, "decode").mockReturnValue({ header: { kid: "key-1" } } as any);
      mockPlaidProvider.plaidClient.webhookVerificationKeyGet.mockRejectedValue(new Error("Key get error"));
      const res2 = await (controller as any).verifyPlaidWebhook("body", "jwt");
      expect(res2).toBe(false);

      // Successful verification path
      const body = '{"test": true}';
      const bodyHash = crypto.createHash("sha256").update(body).digest("hex");

      mockPlaidProvider.plaidClient.webhookVerificationKeyGet.mockResolvedValue({
        data: { key: { kty: "EC", crv: "P-256", x: "x", y: "y" } },
      });

      vi.spyOn(crypto, "createPublicKey").mockReturnValue({} as any);
      vi.spyOn(jwt, "verify").mockReturnValue({ request_body_sha256: bodyHash } as any);

      const res3 = await (controller as any).verifyPlaidWebhook(body, "jwt");
      expect(res3).toBe(true);
    });
  });

  describe("migrateWebhookUrls", () => {
    it("should throw UnauthorizedException if user is not admin", async () => {
      const user = TestEntities.user;
      user.admin = false;

      await expect(controller.migrateWebhookUrls(user, "https://new.url")).rejects.toThrow(UnauthorizedException);
    });

    it("should throw BadRequestException if baseUrl is invalid", async () => {
      const admin = TestEntities.adminUser;
      await expect(controller.migrateWebhookUrls(admin, "invalid-url")).rejects.toThrow(BadRequestException);
    });

    it("should trigger webhook migration when user is admin and URL is valid", async () => {
      const admin = TestEntities.adminUser;
      const res = await controller.migrateWebhookUrls(admin, "https://new.url/");

      expect(res.successCount).toBe(1);
      expect(mockPlaidProvider.updateAllItemWebhooks).toHaveBeenCalledWith("https://new.url");
    });
  });
});
