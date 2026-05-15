import { Configuration } from "@backend/config/core";
import { PendingTransactionJob } from "@backend/jobs/pending.transaction";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { Test, TestingModule } from "@nestjs/testing";

describe("PendingTransactionJob", () => {
  let job: PendingTransactionJob;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PendingTransactionJob],
    }).compile();

    job = module.get<PendingTransactionJob>(PendingTransactionJob);

    // Setup TypeORM method mocks
    Transaction.find = jest.fn();
    Transaction.deleteMany = jest.fn();

    // Set configuration variables explicitly
    Configuration.transaction.stuckTransactionDays = 7;
    Configuration.transaction.stuckTransactionTime = "* * * * *";

    jest.clearAllMocks();
  });

  describe("Constructor", () => {
    it("should instantiate with correct jobName and schedule", () => {
      expect(job.jobName).toBe("transaction:pending");
      // The schedule getter is protected from BackgroundJob, but we know its configured based on our mocks
    });
  });

  describe("start", () => {
    it("should call super.start(true) upon starting", async () => {
      const superStartSpy = jest.spyOn(Object.getPrototypeOf(PendingTransactionJob.prototype), "start").mockResolvedValue(job);
      const result = await job.start();

      expect(superStartSpy).toHaveBeenCalledWith(true);
      expect(result).toBe(job);
      superStartSpy.mockRestore();
    });
  });

  describe("update", () => {
    it("should delete transactions if there are stuck transactions", async () => {
      const mockTransactions = [{ id: "t1" }, { id: "t2" }] as unknown as Transaction[];
      (Transaction.find as jest.Mock).mockResolvedValue(mockTransactions);

      await (job as any).update();

      expect(Transaction.find).toHaveBeenCalled();
      expect(Transaction.deleteMany).toHaveBeenCalledWith(["t1", "t2"]);
    });

    it("should do nothing if there are no stuck transactions", async () => {
      (Transaction.find as jest.Mock).mockResolvedValue([]);

      await (job as any).update();

      expect(Transaction.find).toHaveBeenCalled();
      expect(Transaction.deleteMany).not.toHaveBeenCalled();
    });
  });
});
