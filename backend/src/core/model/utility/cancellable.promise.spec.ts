import { setupTests } from "@backend/test/helpers";
setupTests();

import { CancellablePromise } from "@backend/core/model/utility/cancellable.promise";

describe("CancellablePromise", () => {
  it("should resolve normally when not cancelled", async () => {
    const promise = new CancellablePromise<string>((resolve) => {
      setTimeout(() => resolve("success"), 10);
    });

    const res = await promise;
    expect(res).toBe("success");
  });

  it("should reject with message when cancel is called", async () => {
    const promise = new CancellablePromise<string>((resolve) => {
      setTimeout(() => resolve("success"), 50);
    });

    promise.cancel();

    await expect(promise).rejects.toBe("Promise cancelled");
  });
});
