import { setupTests } from "@backend/test/helpers";
setupTests();

import { CashFlowController } from "@backend/cash-flow/cash.flow.controller";
import { CashFlowService } from "@backend/cash-flow/cash.flow.service";
import { TestEntities } from "@backend/test/entities";
import { Mocked } from "vitest";

describe("CashFlowController", () => {
  let controller: CashFlowController;
  let service: Mocked<CashFlowService>;
  const user = TestEntities.user;

  beforeEach(() => {
    service = {
      buildSankey: vi.fn(),
      calculateFlows: vi.fn(),
      calculateMonthlySpending: vi.fn(),
      getSpendingTimeline: vi.fn(),
      getDailySpendingMap: vi.fn(),
      getLoanAmortizationProjections: vi.fn(),
    } as any;

    controller = new CashFlowController(service);
  });

  describe("getSankey", () => {
    it("should call buildSankey on service", async () => {
      const mockResult = { nodes: [], links: [] };
      service.buildSankey.mockResolvedValue(mockResult as any);

      const res = await controller.getSankey(user, 2026, 5, 12, "acc-1");

      expect(service.buildSankey).toHaveBeenCalledWith(user, 2026, 5, 12, "acc-1");
      expect(res).toBe(mockResult);
    });
  });

  describe("getStats", () => {
    it("should calculate flows and pass defined largestExpense to CashFlowStats", async () => {
      service.calculateFlows.mockResolvedValue({
        totalIncome: 5000,
        totalExpense: 3000,
        transactionCount: 20,
        largestExpense: TestEntities.transaction,
      } as any);

      const stats = await controller.getStats(user, 2026, 5);

      expect(service.calculateFlows).toHaveBeenCalledWith(user, 2026, 5, undefined, undefined);
      expect(stats.totalIncome).toBe(5000);
      expect(stats.totalExpense).toBe(3000);
      expect(stats.count).toBe(20);
      expect(stats.largestExpense).toEqual(TestEntities.transaction);
    });

    it("should fall back to undefined when largestExpense is null", async () => {
      service.calculateFlows.mockResolvedValue({
        totalIncome: 1000,
        totalExpense: 200,
        transactionCount: 5,
        largestExpense: null,
      } as any);

      const stats = await controller.getStats(user, 2026, 5);

      expect(service.calculateFlows).toHaveBeenCalledWith(user, 2026, 5, undefined, undefined);
      expect(stats.largestExpense).toBeUndefined();
    });
  });

  describe("getTrend", () => {
    it("should calculate flows for requested number of months", async () => {
      service.calculateFlows.mockResolvedValue({ totalIncome: 1000, totalExpense: -500 } as any);

      const trend = await controller.getTrend(user, 2);

      expect(trend.length).toBe(2);
      expect(service.calculateFlows).toHaveBeenCalledTimes(2);
    });

    it("should fall back to default of 6 months when monthsQuery is omitted", async () => {
      service.calculateFlows.mockResolvedValue({ totalIncome: 1000, totalExpense: -500 } as any);

      const trend = await controller.getTrend(user);

      expect(trend.length).toBe(6);
      expect(service.calculateFlows).toHaveBeenCalledTimes(6);
    });
  });

  describe("getSpending", () => {
    it("should call calculateMonthlySpending with default or custom parameters", async () => {
      service.calculateMonthlySpending.mockResolvedValue({ categories: [], series: [] } as any);

      await controller.getSpending(user);

      expect(service.calculateMonthlySpending).toHaveBeenCalledWith(user, 6, 4);
    });
  });

  describe("getComparisonTimeline", () => {
    it("should get timelines for baseline and target, handling monthly and yearly modes", async () => {
      service.getSpendingTimeline.mockResolvedValue([{ time: new Date(), value: 10 }] as any);

      const resMonthly = await controller.getComparisonTimeline(user, 2025, 2026, "5", "5");
      expect(resMonthly.currentMonthLabel).toContain("2025");
      expect(resMonthly.targetMonthLabel).toContain("2026");

      const resYearly = await controller.getComparisonTimeline(user, 2025, 2026);
      expect(resYearly.currentMonthLabel).toBe("2025");
      expect(resYearly.targetMonthLabel).toBe("2026");
    });
  });

  describe("getDailyCalendarSpending", () => {
    it("should get daily spending map", async () => {
      service.getDailySpendingMap.mockResolvedValue({ "2026-05-01": 50 } as any);

      const res = await controller.getDailyCalendarSpending(user, 2026, 5);

      expect(service.getDailySpendingMap).toHaveBeenCalledWith(user, 2026, 5);
      expect(res).toEqual({ "2026-05-01": 50 });
    });
  });

  describe("getAmortization", () => {
    it("should get loan amortization projections", async () => {
      service.getLoanAmortizationProjections.mockResolvedValue([]);

      const res = await controller.getAmortization(user);

      expect(service.getLoanAmortizationProjections).toHaveBeenCalledWith(user);
      expect(res).toEqual([]);
    });
  });
});
