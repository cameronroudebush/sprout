import { CurrencyHelper } from "@backend/core/model/utility/currency.helper";
import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";
import { Logger } from "@nestjs/common";

jest.mock("@backend/config/core", () => ({
  Configuration: {
    encryptionKey: "66c60231a85abcf9fa2c6c07fd0b075c50c4a313585afb447c95838ecc6170d8",
    server: {
      auth: {
        secretKey: "test-key",
        oidc: {
          issuer: "https://identity.provider.local",
          clientId: "app-client-id",
        },
      },
      cache: {
        type: "local",
      },
      email: {
        sendTime: "0 12 * * 0",
        validate: jest.fn(),
      },
    },
    holding: {
      cleanupRemovedHoldings: true,
    },
    providers: {
      plaid: {
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
  jest.spyOn(Logger.prototype, "log").mockImplementation(() => {});
  jest.spyOn(Logger.prototype, "error").mockImplementation(() => {});
  jest.spyOn(Logger.prototype, "warn").mockImplementation(() => {});
  jest.spyOn(Logger.prototype, "debug").mockImplementation(() => {});
  jest.spyOn(Logger.prototype, "verbose").mockImplementation(() => {});
}

/** Mocks the database so DatabaseBase will be set */
function mockDatabase() {
  DatabaseBase.database = {
    source: {
      getRepository: jest.fn().mockReturnValue({
        save: jest.fn((arg) => {
          Object.assign(arg, { id: "test-id" });
          return arg;
        }),
        findOne: jest.fn().mockReturnThis(),
      }),
    },
  } as any;
}

/** Mocks DateFns so functions are setup */
function setupMockDateFns() {
  jest.mock("date-fns", () => {
    const original = jest.requireActual("date-fns");
    return {
      ...original,
      subDays: jest.fn((date, amount) => original.subDays(date, amount)),
      startOfDay: jest.fn((date) => original.startOfDay(date)),
      addMinutes: jest.fn((date, amount) => original.addMinutes(date, amount)),
    };
  });
}

/** Mocks various decorators to make sure they are covered */
function setupMockDecorators() {
  jest.spyOn(DatabaseDecorators, "entity").mockImplementation(() => (target: any) => target);
  jest.spyOn(DatabaseDecorators, "column").mockImplementation(() => (_target: any, _propertyKey: string) => {});
  jest.spyOn(DatabaseDecorators, "numericColumn").mockImplementation(() => (_target: any, _propertyKey: string) => {});
  jest.spyOn(DatabaseDecorators, "jsonColumn").mockImplementation(() => (_target: any, _propertyKey: string) => {});
  jest.spyOn(CurrencyHelper, "ExposeCurrencyFields").mockImplementation(() => (target: any) => target);
}
