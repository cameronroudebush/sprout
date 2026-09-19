import { setupTests } from "@backend/test/helpers";
setupTests();

import { CoinbaseProviderController } from "@backend/providers/coinbase/coinbase.controller";
import { CoinbaseProviderService } from "@backend/providers/coinbase/coinbase.provider.service";
import { SSEService } from "@backend/sse/sse.service";
import { TransactionRuleService } from "@backend/transaction/transaction.rule.service";
import { TestEntities } from "@backend/test/entities";
import { Account } from "@backend/account/model/account.model";
import { ProviderType } from "@backend/providers/base/provider.type";
import { SSEEventType } from "@backend/sse/model/event.model";
import { BadRequestException, InternalServerErrorException } from "@nestjs/common";

describe("CoinbaseProviderController", () => {
  let controller: CoinbaseProviderController;
  let coinbaseProviderService: vi.Mocked<CoinbaseProviderService>;
  let sseService: vi.Mocked<SSEService>;
  let transactionRuleService: vi.Mocked<TransactionRuleService>;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.clearAllMocks();

    coinbaseProviderService = {
      exchangeAndCreateAccounts: vi.fn(),
    } as any;

    sseService = {
      sendToUser: vi.fn(),
    } as any;

    transactionRuleService = {
      applyRulesToTransactions: vi.fn().mockResolvedValue(undefined),
    } as any;

    controller = new CoinbaseProviderController(coinbaseProviderService, sseService, transactionRuleService);
  });

  describe("linkAccount", () => {
    it("throws BadRequestException if account is already linked", async () => {
      vi.spyOn(Account, "find").mockResolvedValue([TestEntities.account]);

      await expect(controller.linkAccount(user)).rejects.toThrow(BadRequestException);
      expect(Account.find).toHaveBeenCalledWith({
        where: { user: { id: user.id }, provider: ProviderType.coinbase },
      });
    });

    it("throws InternalServerErrorException if account linking fails to produce an account", async () => {
      vi.spyOn(Account, "find").mockResolvedValue([]);
      coinbaseProviderService.exchangeAndCreateAccounts.mockResolvedValue([]);

      await expect(controller.linkAccount(user)).rejects.toThrow(InternalServerErrorException);
    });

    it("successfully links account, applies rules, and triggers SSE force update", async () => {
      vi.spyOn(Account, "find").mockResolvedValue([]);
      const mockAccount = TestEntities.account;
      coinbaseProviderService.exchangeAndCreateAccounts.mockResolvedValue([{ account: mockAccount }] as any);

      const result = await controller.linkAccount(user);

      expect(result).toBe(mockAccount);
      expect(transactionRuleService.applyRulesToTransactions).toHaveBeenCalledWith(user, undefined, true);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
    });
  });
});
