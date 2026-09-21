import { setupTests } from "@backend/test/helpers";
setupTests();

import { PlaidProviderController } from "@backend/providers/plaid/plaid.controller";
import { PlaidProviderService } from "@backend/providers/plaid/plaid.provider.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TestEntities } from "@backend/test/entities";
import { InternalServerErrorException } from "@nestjs/common";

describe("PlaidProviderController", () => {
  let controller: PlaidProviderController;
  let plaidService: jest.Mocked<PlaidProviderService>;
  let sseService: jest.Mocked<SSEService>;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();

    plaidService = {
      generateLinkToken: jest.fn(),
      exchangeAndCreateAccounts: jest.fn(),
    } as any;

    sseService = {
      sendToUser: jest.fn(),
    } as any;

    controller = new PlaidProviderController(sseService, plaidService);
  });

  describe("createLinkToken", () => {
    it("should return link token dto from provider service", async () => {
      const mockResult = { linkToken: "token-123", expiration: "2026-12-31" };
      plaidService.generateLinkToken.mockResolvedValue(mockResult as any);

      const res = await controller.createLinkToken(user, "https://sprout.local", "inst-1");

      expect(plaidService.generateLinkToken).toHaveBeenCalledWith(user, {
        publicUrl: "https://sprout.local",
        institutionId: "inst-1",
      });
      expect(res).toBe(mockResult);
    });

    it("should throw InternalServerErrorException on error", async () => {
      plaidService.generateLinkToken.mockRejectedValue(new Error("Plaid API Error"));

      await expect(controller.createLinkToken(user, "https://sprout.local")).rejects.toThrow(InternalServerErrorException);
    });
  });

  describe("exchangeAndLink", () => {
    it("should exchange public token, create accounts, and trigger force update", async () => {
      const accounts = [{ account: TestEntities.account }];
      plaidService.exchangeAndCreateAccounts.mockResolvedValue(accounts as any);

      const res = await controller.exchangeAndLink(user, { publicToken: "public-tok", metadata: {} as any });

      expect(plaidService.exchangeAndCreateAccounts).toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res).toBeTruthy();
    });

    it("should throw InternalServerErrorException if exchange fails", async () => {
      plaidService.exchangeAndCreateAccounts.mockRejectedValue(new Error("Exchange failed"));

      await expect(controller.exchangeAndLink(user, { publicToken: "bad-tok", metadata: {} as any })).rejects.toThrow(InternalServerErrorException);
    });
  });
});
