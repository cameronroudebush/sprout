import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { CancellablePromise } from "./cancellable.promise.js";

describe("CancellablePromise", () => {
  class InspectablePromise extends CancellablePromise<string> {
    checkPublic() {
      return this.check();
    }
  }

  it("should resolve normally when not cancelled", async () => {
    const promise = new CancellablePromise<string>((resolve) => {
      setTimeout(() => resolve("success"), 10);
    });

    const res = await promise;
    expect(res).toBe("success");
  });

  it("should reject with message when cancel is called and check cancellation status", async () => {
    let internalPromise: any;
    const promise = new CancellablePromise<string>(function (this: any, resolve) {
      internalPromise = this;
      setTimeout(() => resolve("success"), 50);
    });

    promise.cancel();
    expect(() => internalPromise.check()).toThrow("Promise canceled");

    await expect(promise).rejects.toBe("Promise cancelled");
  });

  it("should not throw from check before cancellation", async () => {
    const promise = new InspectablePromise((resolve) => resolve("ok"));
    expect(() => promise.checkPublic()).not.toThrow();
    await expect(promise).resolves.toBe("ok");
  });
});
