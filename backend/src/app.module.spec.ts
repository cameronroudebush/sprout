import { setupTests } from "@backend/test/helpers";
setupTests();

vi.mock("@keyv/redis", () => {
  const mockKeyvRedis = vi.fn().mockImplementation(function () {
    return {
      client: {
        isOpen: false,
        connect: vi.fn().mockResolvedValue(undefined),
        ping: vi.fn().mockResolvedValue("PONG"),
      },
    };
  });
  const mockKeyv = vi.fn().mockImplementation(function () {
    return {};
  });
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
    vi.clearAllMocks();
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
        apply: vi.fn().mockReturnThis(),
        forRoutes: vi.fn().mockReturnThis(),
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
      const cacheDynamicModule = imports.find((item: any) => item && item.module && item.module.name === "CacheModule");
      const cacheAsyncProvider = cacheDynamicModule?.providers?.find((p: any) => p && p.provide === "CACHE_MODULE_OPTIONS");
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
          validate: vi.fn(),
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
          validate: vi.fn(),
          host: "invalidhost",
          port: 6379,
          password: "",
        },
      } as any;

      const { default: KeyvRedis } = await import("@keyv/redis");
      KeyvRedis.mockImplementationOnce(function () {
        return {
          client: {
            isOpen: false,
            connect: vi.fn().mockRejectedValue(new Error("Redis connection error")),
            ping: vi.fn(),
          },
        };
      });

      const result = await cacheFactory();
      expect(result.stores).toHaveLength(1);
    });
  });
});
