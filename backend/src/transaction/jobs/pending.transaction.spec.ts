import { setupTests } from "@backend/test/helpers";
setupTests();

import { PendingTransactionJob } from "@backend/transaction/jobs/pending.transaction";
import { Transaction } from "@backend/transaction/model/transaction.model";

describe("PendingTransactionJob", () => {
  let job: PendingTransactionJob;

  beforeEach(() => {
    jest.clearAllMocks();
    job = new PendingTransactionJob();
  });

  it("should delete pending transactions older than the configured threshold", async () => {
    const deleteSpy = jest.spyOn(Transaction, "delete").mockResolvedValue({ affected: 5, raw: [] });

    await (job as any).update();

    expect(deleteSpy).toHaveBeenCalledWith({
      pending: true,
      posted: expect.anything(),
    });
  });
});
