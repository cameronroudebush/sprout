import { setupTests } from "@backend/test/helpers";
setupTests();

import { PendingTransactionJob } from "@backend/transaction/jobs/pending.transaction";
import { Transaction } from "@backend/transaction/model/transaction.model";

describe("PendingTransactionJob", () => {
  let job: PendingTransactionJob;

  beforeEach(() => {
    job = new PendingTransactionJob();
  });

  it("should delete pending transactions older than configured threshold and log warning when affected > 0", async () => {
    const deleteSpy = jest.spyOn(Transaction, "delete").mockResolvedValue({ affected: 5 } as any);

    await (job as any).update();

    expect(deleteSpy).toHaveBeenCalledWith({
      pending: true,
      posted: expect.anything(),
    });
  });

  it("should log info when no stuck pending transactions are affected", async () => {
    jest.spyOn(Transaction, "delete").mockResolvedValue({ affected: 0 } as any);

    await (job as any).update();

    expect(Transaction.delete).toHaveBeenCalled();
  });
});
