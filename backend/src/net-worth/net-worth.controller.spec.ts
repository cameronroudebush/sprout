import { setupTests } from "@backend/test/helpers";
setupTests();

import { NetWorthController } from "@backend/net-worth/net-worth.controller";
import { NetWorthService } from "@backend/net-worth/net-worth.service";
import { TestEntities } from "@backend/test/entities";
import { Account } from "@backend/account/model/account.model";
import { NotFoundException } from "@nestjs/common";
import { TotalNetWorthDTO } from "@backend/net-worth/model/api/total.dto";

describe("NetWorthController", () => {
  let controller: NetWorthController;
  let service: Mocked<NetWorthService>;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.clearAllMocks();

    service = {
      getTotalSummary: vi.fn(),
      getNetWorthSummary: vi.fn(),
      getNetWorthByAccounts: vi.fn(),
      getNetWorthByAccount: vi.fn(),
    } as any;

    controller = new NetWorthController(service);
  });

  describe("getNetWorthTotal", () => {
    it("should return TotalNetWorthDTO instance", async () => {
      service.getTotalSummary.mockResolvedValue(10000);

      const mockHistoryList = {
        history: { total: 10000 },
        timeline: vi.fn().mockReturnValue([{ time: "2026-01-01", value: 10000 }]),
      };
      service.getNetWorthSummary.mockResolvedValue(mockHistoryList as any);

      const res = await controller.getNetWorthTotal(user);

      expect(res).toBeInstanceOf(TotalNetWorthDTO);
      expect(res.value).toBe(10000);
    });
  });

  describe("getNetWorthByAccounts", () => {
    it("should return history list for user accounts", async () => {
      service.getNetWorthByAccounts.mockResolvedValue([{ history: { id: "h1" } } as any]);

      const res = await controller.getNetWorthByAccounts(user);

      expect(res).toEqual([{ id: "h1" }]);
    });
  });

  describe("getNetWorthTimelineAccount", () => {
    it("should throw NotFoundException if account not found", async () => {
      vi.spyOn(Account, "findOne").mockResolvedValue(null);

      await expect(controller.getNetWorthTimelineAccount("acc-invalid", user)).rejects.toThrow(NotFoundException);
    });

    it("should return timeline for specified account", async () => {
      const account = TestEntities.account;
      vi.spyOn(Account, "findOne").mockResolvedValue(account);

      const mockHistoryList = {
        timeline: vi.fn().mockReturnValue([{ time: "2026-01-01", value: 500 }]),
      };
      service.getNetWorthByAccount.mockResolvedValue(mockHistoryList as any);

      const res = await controller.getNetWorthTimelineAccount(account.id, user);

      expect(res).toEqual([{ time: "2026-01-01", value: 500 }]);
    });
  });
});
