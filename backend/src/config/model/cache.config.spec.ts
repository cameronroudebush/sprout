import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { CacheConfig } from "./cache.config.js";

describe("CacheConfig", () => {
  it("should initialize default cache options and validate redis configuration", () => {
    const config = new CacheConfig();
    expect(config.type).toBe("local");

    config.type = "redis";
    config.redis.host = "localhost";
    config.redis.port = 6379;
    expect(() => config.redis.validate()).not.toThrow();

    config.redis.host = "";
    expect(() => config.redis.validate()).toThrow("The host must be set for cache type of redis.");

    config.redis.host = "localhost";
    config.redis.port = 0;
    expect(() => config.redis.validate()).toThrow("The port must be set for cache type of redis.");
  });
});
