import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { AccountMergeDTO } from "./account.merge.dto.js";

describe("AccountMergeDTO", () => {
  it("should create DTO instance with source ID", () => {
    const dto = new AccountMergeDTO("source-123");
    expect(dto.sourceId).toBe("source-123");
  });
});
