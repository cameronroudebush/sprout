import { SproutLogger } from "@backend/core/logger";
import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { Logger } from "@nestjs/common";

// Zillow's native scraper binding requires newer glibc than some test environments provide.
vi.mock("impit", () => ({
  Impit: class {
    fetch = vi.fn();
  },
}));

vi.mock("@backend/config/core", () => ({
  Configuration: {
    appName: "sprout",
    writeConfigFile: true,
    isDevBuild: false,
    encryptionKey: "66c60231a85abcf9fa2c6c07fd0b075c50c4a313585afb447c95838ecc6170d8",
    isDemoMode: false,
    version: "1.0.0",
    database: {
      backup: {
        enabled: true,
        time: "0 7 * * *",
        directory: "/backups/database",
        gfs: {
          dailyCount: 7,
          weeklyCount: 4,
          monthlyCount: 12,
          quarterlyCount: 4,
          yearlyCount: 3,
        },
      },
    },
    server: {
      auth: {
        type: "local",
        secretKey: "test-key",
        oidc: {
          issuer: "https://identity.provider.local",
          clientId: "app-client-id",
        },
      },
      rateLimit: {
        ttl: 60,
        limit: 100,
      },
      cache: {
        type: "local",
      },
      email: {
        enabled: true,
        sendTime: "0 12 * * 0",
        validate: vi.fn(),
      },
      notification: {
        maxNotificationsPerUser: 50,
        firebase: {
          enabled: false,
          apiKey: "test-api-key",
          appId: "test-app-id",
          projectNumber: 12345,
          projectId: "test-project-id",
          clientEmail: "test@project.iam.gserviceaccount.com",
          privateKey: "test-private-key",
          validate: vi.fn(),
        },
      },
      prompt: {
        type: "gemini",
        enabled: true,
        gemini: {
          key: "test-gemini-key",
          chatModel: "gemini-2.5-flash",
          overviewModel: "gemini-2.5-flash",
        },
        openCode: {
          key: "test-opencode-key",
          chatModel: "opencode-chat-model",
          overviewModel: "opencode-overview-model",
        },
      },
      lightModeTiles: [],
      darkModeTiles: [],
      brandFetch: { clientId: "bf-id", getWebsiteIconUrl: vi.fn().mockReturnValue("https://icon.local") },
      exchangeRate: {
        time: "0 0 * * *",
      },
    },
    holding: {
      cleanupRemovedHoldings: true,
    },
    transaction: {
      stuckTransactions: {
        time: "0 0 * * *",
        enabled: true,
        days: 7,
      },
    },
    user: {
      deviceCheck: {
        time: "0 0 * * *",
        enabled: true,
        days: 30,
      },
    },
    providers: {
      postSyncTime: "0 0 * * *",
      syncNotifications: { enabled: true },
      plaid: {
        enabled: true,
      },
      simpleFIN: {
        enabled: true,
        syncFrequency: "0 0 * * *",
      },
      snapTrade: {
        enabled: true,
        consumerKey: "test-key",
      },
      zillow: {
        enabled: true,
      },
      coinbase: {
        enabled: true,
      },
    },
  },
}));

/** Mocks a bunch of content that is used across the app */
export function setupTests() {
  mockLogger();
  mockDatabase();
  setupMockDateFns();
  setupMockDecorators();
}

/** Mocks the logger to not actually output and litter the log for testing */
function mockLogger() {
  // Disable NestJS builtin logger
  Logger.overrideLogger(false);

  // Silence process output streams (catches custom loggers writing directly to stdout/stderr)
  vi.spyOn(process.stdout, "write").mockImplementation(() => true);
  vi.spyOn(process.stderr, "write").mockImplementation(() => true);

  // Silence standard console
  vi.spyOn(console, "log").mockImplementation(() => {});
  vi.spyOn(console, "error").mockImplementation(() => {});
  vi.spyOn(console, "warn").mockImplementation(() => {});
  vi.spyOn(console, "debug").mockImplementation(() => {});

  // Spy prototypes for Nest Logger & SproutLogger
  vi.spyOn(Logger.prototype, "log").mockImplementation(() => {});
  vi.spyOn(Logger.prototype, "error").mockImplementation(() => {});
  vi.spyOn(Logger.prototype, "warn").mockImplementation(() => {});
  vi.spyOn(Logger.prototype, "debug").mockImplementation(() => {});
  vi.spyOn(Logger.prototype, "verbose").mockImplementation(() => {});

  vi.spyOn(SproutLogger.prototype, "log").mockImplementation(() => {});
  vi.spyOn(SproutLogger.prototype, "error").mockImplementation(() => {});
  vi.spyOn(SproutLogger.prototype, "warn").mockImplementation(() => {});
  vi.spyOn(SproutLogger.prototype, "debug").mockImplementation(() => {});
  vi.spyOn(SproutLogger.prototype, "verbose").mockImplementation(() => {});
}

/** Mocks the database so DatabaseBase will be set */
function mockDatabase() {
  DatabaseBase.database = {
    source: {
      getRepository: vi.fn().mockReturnValue({
        save: vi.fn((arg) => {
          Object.assign(arg, { id: "test-id" });
          return arg;
        }),
        findOne: vi.fn().mockReturnThis(),
      }),
    },
  } as any;
}

/** Mocks DateFns so functions are setup */
function setupMockDateFns() {}

/** Mocks various decorators to make sure they are covered */
function setupMockDecorators() {
  vi.spyOn(DatabaseDecorators, "entity").mockImplementation(() => (target: any) => target);
  vi.spyOn(DatabaseDecorators, "column").mockImplementation(() => (_target: any, _propertyKey: string) => {});
  vi.spyOn(DatabaseDecorators, "numericColumn").mockImplementation(() => (_target: any, _propertyKey: string) => {});
  vi.spyOn(DatabaseDecorators, "jsonColumn").mockImplementation(() => (_target: any, _propertyKey: string) => {});
  vi.spyOn(CurrencyHelper, "ExposeCurrencyFields").mockImplementation(() => (target: any) => target);
}
