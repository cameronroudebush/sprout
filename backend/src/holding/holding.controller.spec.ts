import { setupTests } from "@backend/test/helpers";
setupTests();

import { Account } from "@backend/account/model/account.model";
import { HoldingController } from "@backend/holding/holding.controller";
import { HoldingService } from "@backend/holding/holding.service";
import { Holding } from "@backend/holding/model/holding.model";
import { NetWorthService } from "@backend/net-worth/net-worth.service";
import { TestEntities } from "@backend/test/entities";
import { BadRequestException, NotFoundException } from "@nestjs/common";

describe("HoldingController", () => {
  let controller: HoldingController;
  let holdingService: jest.Mocked<HoldingService>;
  let netWorthService: jest.Mocked<NetWorthService>;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();

    holdingService = {
      getMajorIndices: jest.fn(),
      getMajorIndicesTimeline: jest.fn(),
      getTimelineForHolding: jest.fn(),
      getLiveHoldingPrices: jest.fn(),
    } as any;

    netWorthService = {
      getHistoryForHoldings: jest.fn(),
      getHistoryForHolding: jest.fn(),
    } as any;

    controller = new HoldingController(holdingService, netWorthService);
  });

  describe("getHoldings", () => {
    it("should throw NotFoundException if account does not exist", async () => {
      jest.spyOn(Account, "findOne").mockResolvedValue(null);

      await expect(controller.getHoldings(user, "invalid-acc")).rejects.toThrow(NotFoundException);
    });

    it("should return holdings for valid account", async () => {
      const account = TestEntities.account;
      const holdings = [TestEntities.holding];
      jest.spyOn(Account, "findOne").mockResolvedValue(account);
      jest.spyOn(Holding, "getForAccount").mockResolvedValue(holdings as any);

      const res = await controller.getHoldings(user, account.id);

      expect(res).toBe(holdings);
    });
  });

  describe("getHoldingHistory", () => {
    it("should throw NotFoundException if account is missing or not investment type", async () => {
      jest.spyOn(Account, "findOne").mockResolvedValue(null);

      await expect(controller.getHoldingHistory(user, "invalid-acc")).rejects.toThrow(NotFoundException);
    });

    it("should return mapped history for holdings", async () => {
      const account = TestEntities.account;
      jest.spyOn(Account, "findOne").mockResolvedValue(account);
      netWorthService.getHistoryForHoldings.mockResolvedValue([{ history: { id: "h1" } } as any]);

      const res = await controller.getHoldingHistory(user, account.id);

      expect(res).toEqual([{ id: "h1" }]);
    });
  });

  describe("getSpecificHoldingHistory", () => {
    it("should throw NotFoundException if holding not found", async () => {
      jest.spyOn(Holding, "findOne").mockResolvedValue(null);

      await expect(controller.getSpecificHoldingHistory("h-invalid", user)).rejects.toThrow(NotFoundException);
    });

    it("should return history for holding", async () => {
      const holding = TestEntities.holding;
      jest.spyOn(Holding, "findOne").mockResolvedValue(holding);
      netWorthService.getHistoryForHolding.mockResolvedValue({ history: { id: "h1" } } as any);

      const res = await controller.getSpecificHoldingHistory(holding.id, user);

      expect(res).toEqual({ id: "h1" });
    });
  });

  describe("getLiveMajor", () => {
    it("should call getMajorIndices", async () => {
      holdingService.getMajorIndices.mockResolvedValue([]);

      const res = await controller.getLiveMajor(user);

      expect(holdingService.getMajorIndices).toHaveBeenCalled();
      expect(res).toEqual([]);
    });
  });

  describe("getMajorIndicesTimeline", () => {
    it("should call getMajorIndicesTimeline", async () => {
      holdingService.getMajorIndicesTimeline.mockResolvedValue([]);

      const res = await controller.getMajorIndicesTimeline(user);

      expect(holdingService.getMajorIndicesTimeline).toHaveBeenCalled();
      expect(res).toEqual([]);
    });
  });

  describe("getHoldingTimeline", () => {
    it("should throw NotFoundException if holding not found", async () => {
      jest.spyOn(Holding, "findOne").mockResolvedValue(null);

      await expect(controller.getHoldingTimeline("h-invalid", user)).rejects.toThrow(NotFoundException);
    });

    it("should return timeline for holding", async () => {
      const holding = TestEntities.holding;
      jest.spyOn(Holding, "findOne").mockResolvedValue(holding);

      const mockHoldingHistoryList = {
        timeline: jest.fn().mockReturnValue([{ time: "2026-01-01", value: 100 }]),
      };
      holdingService.getTimelineForHolding.mockResolvedValue(mockHoldingHistoryList as any);

      const res = await controller.getHoldingTimeline(holding.id, user);

      expect(res).toEqual([{ time: "2026-01-01", value: 100 }]);
    });
  });

  describe("getLivePrices", () => {
    it("should throw BadRequestException if symbols is null or empty", async () => {
      await expect(controller.getLivePrices(user, null as any)).rejects.toThrow(BadRequestException);
    });

    it("should call getLiveHoldingPrices for symbols", async () => {
      holdingService.getLiveHoldingPrices.mockResolvedValue([]);

      const res = await controller.getLivePrices(user, ["AAPL", "MSFT"]);

      expect(holdingService.getLiveHoldingPrices).toHaveBeenCalledWith(["AAPL", "MSFT"]);
      expect(res).toEqual([]);
    });
  });
});
