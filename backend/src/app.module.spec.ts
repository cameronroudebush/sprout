import { setupTests } from "@backend/test/helpers";
setupTests();

jest.mock("@keyv/redis", () => {
  const mockKeyvRedis = jest.fn().mockImplementation(() => ({
    client: {
      isOpen: false,
      connect: jest.fn().mockResolvedValue(undefined),
      ping: jest.fn().mockResolvedValue("PONG"),
    },
  }));
  const mockKeyv = jest.fn().mockImplementation(() => ({}));
  return {
    __esModule: true,
    default: mockKeyvRedis,
    Keyv: mockKeyv,
  };
});

import { AppModule } from "@backend/app.module";
import { Configuration } from "@backend/config/core";
import { CacheModuleOptions } from "@nestjs/cache-manager";
import { MODULE_METADATA } from "@nestjs/common/constants";

describe("AppModule", () => {
  let originalCacheConfig: any;

  beforeEach(() => {
    jest.clearAllMocks();
    originalCacheConfig = { ...Configuration.server.cache };
  });

  afterEach(() => {
    Configuration.server.cache = originalCacheConfig;
  });

  it("should define AppModule class", () => {
    expect(AppModule).toBeDefined();
  });

  describe("configure", () => {
    it("should configure middleware consumer", () => {
      const appModule = new AppModule();
      const consumer = {
        apply: jest.fn().mockReturnThis(),
        forRoutes: jest.fn().mockReturnThis(),
      };

      appModule.configure(consumer as any);

      expect(consumer.apply).toHaveBeenCalled();
      expect(consumer.forRoutes).toHaveBeenCalledWith("*path");
    });
  });

  describe("CacheModule factory", () => {
    let cacheFactory: () => Promise<CacheModuleOptions>;

    beforeAll(() => {
      const imports = Reflect.getMetadata(MODULE_METADATA.IMPORTS, AppModule) || [];
      const cacheDynamicModule = imports.find(
        (item: any) => item && item.module && item.module.name === "CacheModule",
      );
      const cacheAsyncProvider = cacheDynamicModule?.providers?.find(
        (p: any) => p && p.provide === "CACHE_MODULE_OPTIONS",
      );
      cacheFactory = cacheAsyncProvider?.useFactory;
    });

    it("should configure memory store when cache type is memory", async () => {
      Configuration.server.cache = {
        type: "memory",
      } as any;

      const result = await cacheFactory();
      expect(result.stores).toHaveLength(1);
    });

    it("should configure redis store when cache type is redis and connection succeeds", async () => {
      Configuration.server.cache = {
        type: "redis",
        redis: {
          validate: jest.fn(),
          host: "localhost",
          port: 6379,
          password: "secretpassword",
        },
      } as any;

      const result = await cacheFactory();
      expect(Configuration.server.cache.redis.validate).toHaveBeenCalled();
      expect(result.stores).toBeDefined();
    });

    it("should fallback to L1 cache when redis connection fails or times out", async () => {
      Configuration.server.cache = {
        type: "redis",
        redis: {
          validate: jest.fn(),
          host: "invalidhost",
          port: 6379,
          password: "",
        },
      } as any;

      const KeyvRedis = require("@keyv/redis").default;
      KeyvRedis.mockImplementationOnce(() => ({
        client: {
          isOpen: false,
          connect: jest.fn().mockRejectedValue(new Error("Redis connection error")),
          ping: jest.fn(),
        },
      }));

      const result = await cacheFactory();
      expect(result.stores).toHaveLength(1);
    });
  });
});
