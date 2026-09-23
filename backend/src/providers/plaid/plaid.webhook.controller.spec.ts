import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ProviderSyncService } from "@backend/providers/base/sync.service.js";
import { PlaidInstitutionAsset } from "@backend/providers/plaid/model/plaid.institution.asset.js";
import { PlaidProviderService } from "@backend/providers/plaid/plaid.provider.service.js";
import { PlaidWebhookController } from "@backend/providers/plaid/plaid.webhook.controller.js";
import { TestEntities } from "@backend/test/entities.js";
import { BadRequestException, UnauthorizedException } from "@nestjs/common";
import crypto from "crypto";
import jwt from "jsonwebtoken";
import { Mocked } from "vitest";

describe("PlaidWebhookController", () => {
  let controller: PlaidWebhookController;
  let plaidProvider: Mocked<PlaidProviderService>;
  let providerSyncService: Mocked<ProviderSyncService>;

  beforeEach(() => {
    vi.restoreAllMocks();
    plaidProvider = {
      updateAllItemWebhooks: vi.fn().mockResolvedValue({ updatedCount: 2, failedCount: 0 }),
      plaidClient: {
        webhookVerificationKeyGet: vi.fn(),
      },
    } as any;

    providerSyncService = {
      syncForProvider: vi.fn().mockResolvedValue(undefined),
      flagInstitution: vi.fn().mockResolvedValue(undefined),
    } as any;

    controller = new PlaidWebhookController(plaidProvider, providerSyncService);
  });

  describe("handlePlaidWebhook", () => {
    it("should throw BadRequestException if signature header is missing", async () => {
      const headers = {};
      const req: any = { rawBody: Buffer.from("body") };

      await expect(controller.handlePlaidWebhook(headers, req, {} as any)).rejects.toThrow(BadRequestException);
    });

    it("should accept plaid-verification-signature header alternative", async () => {
      const headers = { "plaid-verification-signature": "jwt-sig" };
      const req: any = { rawBody: Buffer.from("body") };
      vi.spyOn(controller as any, "verifyPlaidWebhook").mockResolvedValue(true);
      vi.spyOn(controller as any, "handleWebhook").mockImplementation(() => Promise.resolve());

      const res = await controller.handlePlaidWebhook(headers, req, { webhook_type: "TRANSACTIONS", webhook_code: "SYNC_UPDATES_AVAILABLE" } as any);
      expect(res).toEqual({ status: "received" });
    });

    it("should throw BadRequestException if rawBody is missing", async () => {
      const headers = { "plaid-verification": "jwt-sig" };
      const req: any = {};

      await expect(controller.handlePlaidWebhook(headers, req, {} as any)).rejects.toThrow(BadRequestException);
    });

    it("should throw BadRequestException if verification fails", async () => {
      const headers = { "plaid-verification": "jwt-sig" };
      const req: any = { rawBody: Buffer.from("body") };
      vi.spyOn(controller as any, "verifyPlaidWebhook").mockResolvedValue(false);

      await expect(controller.handlePlaidWebhook(headers, req, {} as any)).rejects.toThrow(BadRequestException);
    });

    it("should process webhook and return received status when signature is valid", async () => {
      const headers = { "plaid-verification": "jwt-sig" };
      const req: any = { rawBody: Buffer.from("body") };
      vi.spyOn(controller as any, "verifyPlaidWebhook").mockResolvedValue(true);
      const handleWebhookSpy = vi.spyOn(controller as any, "handleWebhook").mockImplementation(() => Promise.resolve());

      const res = await controller.handlePlaidWebhook(headers, req, { webhook_type: "TRANSACTIONS", webhook_code: "SYNC_UPDATES_AVAILABLE" } as any);

      expect(res).toEqual({ status: "received" });
      expect(handleWebhookSpy).toHaveBeenCalled();
    });
  });

  describe("migrateWebhookUrls", () => {
    it("should throw UnauthorizedException if user is not admin", async () => {
      const nonAdminUser = TestEntities.user; // admin: false
      await expect(controller.migrateWebhookUrls(nonAdminUser, "https://new-url.com")).rejects.toThrow(UnauthorizedException);
    });

    it("should throw BadRequestException if baseUrl is invalid", async () => {
      const adminUser = TestEntities.adminUser;
      await expect(controller.migrateWebhookUrls(adminUser, "invalid-url")).rejects.toThrow(BadRequestException);
    });

    it("should call updateAllItemWebhooks and return migration result when admin", async () => {
      const adminUser = TestEntities.adminUser;
      const res = await controller.migrateWebhookUrls(adminUser, "https://new-url.com///");

      expect(plaidProvider.updateAllItemWebhooks).toHaveBeenCalledWith("https://new-url.com");
      expect(res.message).toBe("Webhook migration sequence complete.");
      expect(res.updatedCount).toBe(2);
    });
  });

  describe("handleWebhook internal logic", () => {
    it("should trigger syncForProvider on TRANSACTIONS:SYNC_UPDATES_AVAILABLE", async () => {
      const user = TestEntities.user;
      const mockAsset = {
        item_id: "item-123",
        institution: { ...TestEntities.institution, user },
      };
      vi.spyOn(PlaidInstitutionAsset, "findOne").mockResolvedValue(mockAsset as any);

      await (controller as any).handleWebhook({
        webhook_type: "TRANSACTIONS",
        webhook_code: "SYNC_UPDATES_AVAILABLE",
        item_id: "item-123",
      });

      expect(PlaidInstitutionAsset.findOne).toHaveBeenCalled();
      expect(providerSyncService.syncForProvider).toHaveBeenCalled();
    });

    it("should flag institution broken on ITEM:ERROR", async () => {
      const user = TestEntities.user;
      const mockAsset = {
        item_id: "item-123",
        institution: { ...TestEntities.institution, user },
      };
      vi.spyOn(PlaidInstitutionAsset, "findOne").mockResolvedValue(mockAsset as any);

      await (controller as any).handleWebhook({
        webhook_type: "ITEM",
        webhook_code: "ERROR",
        item_id: "item-123",
      });

      expect(providerSyncService.flagInstitution).toHaveBeenCalledWith(mockAsset.institution, true);
    });

    it("should trigger syncForProvider on HOLDINGS:DEFAULT_UPDATE and INVESTMENTS_TRANSACTIONS:HISTORICAL_UPDATE", async () => {
      const user = TestEntities.user;
      const mockAsset = {
        item_id: "item-123",
        institution: { ...TestEntities.institution, user },
      };
      vi.spyOn(PlaidInstitutionAsset, "findOne").mockResolvedValue(mockAsset as any);

      await (controller as any).handleWebhook({
        webhook_type: "HOLDINGS",
        webhook_code: "DEFAULT_UPDATE",
        item_id: "item-123",
      });

      await (controller as any).handleWebhook({
        webhook_type: "INVESTMENTS_TRANSACTIONS",
        webhook_code: "HISTORICAL_UPDATE",
        item_id: "item-123",
      });

      expect(providerSyncService.syncForProvider).toHaveBeenCalledTimes(2);
    });

    it("should log unknown webhook codes or types", async () => {
      await (controller as any).handleWebhook({
        webhook_type: "TRANSACTIONS",
        webhook_code: "UNKNOWN_CODE",
      });

      await (controller as any).handleWebhook({
        webhook_type: "ITEM",
        webhook_code: "UNKNOWN_CODE",
      });

      await (controller as any).handleWebhook({
        webhook_type: "HOLDINGS",
        webhook_code: "UNKNOWN_CODE",
      });

      await (controller as any).handleWebhook({
        webhook_type: "UNKNOWN_TYPE",
        webhook_code: "UNKNOWN_CODE",
      });

      expect(providerSyncService.syncForProvider).not.toHaveBeenCalled();
    });

    it("should handle exceptions gracefully in handleWebhook", async () => {
      vi.spyOn(PlaidInstitutionAsset, "findOne").mockRejectedValue(new Error("DB error"));

      await expect(
        (controller as any).handleWebhook({
          webhook_type: "TRANSACTIONS",
          webhook_code: "SYNC_UPDATES_AVAILABLE",
          item_id: "item-123",
        }),
      ).resolves.not.toThrow();
    });
  });

  describe("getPlaidInstitutionAsset", () => {
    it("should throw BadRequestException when item_id is missing or asset not found", async () => {
      await expect((controller as any).getPlaidInstitutionAsset({})).rejects.toThrow(BadRequestException);

      vi.spyOn(PlaidInstitutionAsset, "findOne").mockResolvedValue(null);
      await expect((controller as any).getPlaidInstitutionAsset({ item_id: "missing" })).rejects.toThrow(BadRequestException);
    });
  });

  describe("verifyPlaidWebhook", () => {
    it("should verify webhook signature correctly or return false on error", async () => {
      const verifyFn = (controller as any).verifyPlaidWebhook.bind(controller);

      // Invalid JWT decode
      vi.spyOn(jwt, "decode").mockReturnValue(null as any);
      expect(await verifyFn("body", "jwt")).toBe(false);

      // Decoded without kid header
      vi.spyOn(jwt, "decode").mockReturnValue({ header: {} } as any);
      expect(await verifyFn("body", "jwt")).toBe(false);

      // Valid decoded JWT header with kid, failed verification key fetch
      vi.spyOn(jwt, "decode").mockReturnValue({ header: { kid: "kid-1" } } as any);
      plaidProvider.plaidClient.webhookVerificationKeyGet = vi.fn().mockRejectedValue(new Error("Key fetch failed"));
      expect(await verifyFn("body", "jwt")).toBe(false);

      // Successful key fetch returning falsy cached key
      plaidProvider.plaidClient.webhookVerificationKeyGet = vi.fn().mockResolvedValue({ data: { key: null } });
      expect(await verifyFn("body", "jwt")).toBe(false);

      // Successful verification key fetch, but jwt.verify fails
      const mockKey = { kty: "EC", crv: "P-256", x: "x", y: "y" };
      (controller as any).cachedKey = undefined;
      plaidProvider.plaidClient.webhookVerificationKeyGet = vi.fn().mockResolvedValue({ data: { key: mockKey } });
      vi.spyOn(crypto, "createPublicKey").mockReturnValue({} as any);
      vi.spyOn(jwt, "verify").mockImplementation(() => {
        throw new Error("Invalid JWT signature");
      });
      expect(await verifyFn("body", "jwt")).toBe(false);

      // Successful jwt.verify and hash comparison
      const body = "test-body";
      const computedHash = crypto.createHash("sha256").update(body).digest("hex");
      vi.spyOn(jwt, "verify").mockReturnValue({ request_body_sha256: computedHash } as any);
      expect(await verifyFn(body, "jwt")).toBe(true);

      // Claimed body hash missing in payload
      vi.spyOn(jwt, "verify").mockReturnValue({ request_body_sha256: undefined } as any);
      expect(await verifyFn(body, "jwt")).toBe(false);

      // Valid signature structure with a mismatching body hash.
      vi.spyOn(jwt, "verify").mockReturnValue({ request_body_sha256: "0".repeat(64) } as any);
      expect(await verifyFn(body, "jwt")).toBe(false);

      // A decoded string is not a usable JWT payload.
      vi.spyOn(jwt, "decode").mockReturnValue("decoded" as any);
      expect(await verifyFn(body, "jwt")).toBe(false);

      vi.spyOn(jwt, "decode").mockReturnValue({ header: { kid: "kid-unexpected" } } as any);
      (controller as any).cachedKey = undefined;
      plaidProvider.plaidClient.webhookVerificationKeyGet = vi.fn().mockResolvedValue({ data: { key: mockKey } });
      vi.spyOn(crypto, "createPublicKey").mockImplementation(() => {
        throw new Error("invalid public key");
      });
      expect(await verifyFn(body, "jwt")).toBe(false);
    });
  });
});
