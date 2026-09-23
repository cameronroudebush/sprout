import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it, vi } from "vitest";

setupTests();

import { ProviderRateLimit } from "@backend/providers/base/rate-limit.js";
import { ProviderType } from "@backend/providers/base/provider.type.js";
import { TestEntities } from "@backend/test/entities.js";
import { HttpException, HttpStatus } from "@nestjs/common";

describe("ProviderRateLimit", () => {
  const user = TestEntities.user;

  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it("should create new rate limit record if not found in db", async () => {
    const rateLimit = new ProviderRateLimit(ProviderType.plaid, 10, user);
    vi.spyOn(ProviderRateLimit, "findOne").mockResolvedValue(null);
    const insertSpy = vi.spyOn(rateLimit, "insert").mockResolvedValue(rateLimit);

    await rateLimit.incrementOrError();

    expect(rateLimit.count).toBe(1);
    expect(insertSpy).toHaveBeenCalled();
  });

  it("should throw HttpException when rate limit exceeded on same day", async () => {
    const rateLimit = new ProviderRateLimit(ProviderType.plaid, 5, user);

    const existingInDb = new ProviderRateLimit(ProviderType.plaid, 5, user);
    existingInDb.count = 5;
    existingInDb.lastUpdated = new Date();

    vi.spyOn(ProviderRateLimit, "findOne").mockResolvedValue(existingInDb);

    await expect(rateLimit.incrementOrError()).rejects.toThrow(HttpException);
  });

  it("should reset count to 1 when date changes", async () => {
    const rateLimit = new ProviderRateLimit(ProviderType.plaid, 5, user);

    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);

    const existingInDb = new ProviderRateLimit(ProviderType.plaid, 5, user);
    existingInDb.count = 5;
    existingInDb.lastUpdated = yesterday;
    existingInDb.update = vi.fn().mockResolvedValue(existingInDb);

    vi.spyOn(ProviderRateLimit, "findOne").mockResolvedValue(existingInDb);

    await rateLimit.incrementOrError();

    expect(existingInDb.count).toBe(1);
    expect(existingInDb.update).toHaveBeenCalled();
  });

  it("should increment count when within limit on same day", async () => {
    const rateLimit = new ProviderRateLimit(ProviderType.plaid, 10, user);

    const existingInDb = new ProviderRateLimit(ProviderType.plaid, 10, user);
    existingInDb.count = 3;
    existingInDb.lastUpdated = new Date();
    existingInDb.update = vi.fn().mockResolvedValue(existingInDb);

    vi.spyOn(ProviderRateLimit, "findOne").mockResolvedValue(existingInDb);

    await rateLimit.incrementOrError();

    expect(existingInDb.count).toBe(4);
    expect(existingInDb.update).toHaveBeenCalled();
  });

  it("should omit user from lookup when no user is provided", async () => {
    const rateLimit = new ProviderRateLimit(ProviderType.plaid, 10);
    vi.spyOn(ProviderRateLimit, "findOne").mockResolvedValue(null);
    vi.spyOn(rateLimit, "insert").mockResolvedValue(rateLimit);

    await rateLimit.incrementOrError();

    expect(ProviderRateLimit.findOne).toHaveBeenCalledWith({ where: { name: ProviderType.plaid } });
  });
});
