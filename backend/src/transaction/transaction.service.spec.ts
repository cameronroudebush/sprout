import { setupTests } from "@backend/test/helpers";
setupTests();

vi.mock("fs/promises", () => ({
  readFile: vi.fn().mockResolvedValue("SELECT 1;"),
}));

import { TestEntities } from "@backend/test/entities";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionService } from "@backend/transaction/transaction.service";

describe("TransactionService", () => {
  let service: TransactionService;
  let mockDatabaseService: any;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.clearAllMocks();

    mockDatabaseService = {
      source: {
        query: vi.fn(),
      },
    };

    service = new TransactionService(mockDatabaseService as any);
  });

  describe("findSubscriptions", () => {
    it("should process query results and filter active subscriptions", async () => {
      const today = new Date();
      const lastPosted = new Date(); // today
      const firstPosted = new Date(today.getTime() - 60 * 24 * 60 * 60 * 1000);

      const mockRow = {
        last_posted: lastPosted.toISOString(),
        first_posted: firstPosted.toISOString(),
        avg_days_between: 30,
        transaction_count: 3,
        latest_description: "Netflix",
        avg_amount: 15.99,
        transactionId: "tx-sub-1",
      };

      mockDatabaseService.source.query.mockResolvedValue([mockRow]);
      vi.spyOn(Transaction, "findOne").mockResolvedValue(TestEntities.transaction);

      const results = await service.findSubscriptions(user);

      expect(mockDatabaseService.source.query).toHaveBeenCalled();
      expect(results).toHaveLength(1);
      expect(results[0]?.description).toBe("Netflix");
    });

    it("should filter out inactive overdue subscriptions", async () => {
      const lastPosted = new Date(Date.now() - 100 * 24 * 60 * 60 * 1000); // 100 days ago

      const mockRow = {
        last_posted: lastPosted.toISOString(),
        first_posted: lastPosted.toISOString(),
        avg_days_between: 30,
        transaction_count: 2,
        latest_description: "Old Sub",
        avg_amount: 10.0,
        transactionId: "tx-sub-2",
      };

      mockDatabaseService.source.query.mockResolvedValue([mockRow]);

      const results = await service.findSubscriptions(user, 40);

      expect(results).toHaveLength(0);
    });
  });
});
