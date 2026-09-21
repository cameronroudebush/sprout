import { setupTests } from "@backend/test/helpers.js";
setupTests();

vi.unmock("./generate.migration.js");
vi.unmock("@backend/scripts/generate.migration.js");

import { generateMigration } from "./generate.migration.js";
import { NestFactory } from "@nestjs/core";
import prettier from "prettier";
import { CommandUtils } from "typeorm/commands/CommandUtils.js";

vi.mock("@nestjs/core", async (importOriginal) => {
  const actual: any = await importOriginal();
  return {
    ...actual,
    NestFactory: {
      create: vi.fn(),
    },
  };
});

vi.mock("prettier", () => ({
  default: {
    format: vi.fn().mockResolvedValue("formatted ts content"),
  },
}));

vi.mock("typeorm/commands/CommandUtils.js", () => ({
  CommandUtils: {
    createFile: vi.fn().mockResolvedValue(undefined),
  },
}));

describe("generateMigration", () => {
  let mockDatabaseService: any;
  let mockApp: any;

  beforeEach(() => {
    vi.restoreAllMocks();

    const mockInit = vi.fn().mockResolvedValue("init_res");

    mockDatabaseService = {
      source: {
        isInitialized: false,
        initialize: mockInit,
        driver: {
          createSchemaBuilder: vi.fn().mockReturnValue({
            log: vi.fn().mockResolvedValue({
              upQueries: [{ query: "CREATE TABLE `test` (`id` int)", parameters: ["p1"] }],
              downQueries: [{ query: "DROP TABLE `test`", parameters: [] }],
            }),
          }),
        },
      },
      setSQLitePRAGMA: vi.fn().mockResolvedValue(undefined),
    };

    mockApp = {
      get: vi.fn().mockReturnValue(mockDatabaseService),
      close: vi.fn().mockResolvedValue(undefined),
    };

    (NestFactory.create as any).mockResolvedValue(mockApp);
  });

  it("should generate migration file when schema changes exist", async () => {
    await generateMigration("test_migration");

    expect(mockDatabaseService.setSQLitePRAGMA).toHaveBeenCalledWith(false);
    expect(prettier.format).toHaveBeenCalled();
    expect(CommandUtils.createFile).toHaveBeenCalled();
    expect(mockApp.close).toHaveBeenCalled();
  });

  it("should skip initialization when source is already initialized", async () => {
    mockDatabaseService.source.isInitialized = true;
    await generateMigration("test_migration_initialized");

    expect(prettier.format).toHaveBeenCalled();
    expect(CommandUtils.createFile).toHaveBeenCalled();
    expect(mockApp.close).toHaveBeenCalled();
  });

  it("should return early when no upQueries are present", async () => {
    mockDatabaseService.source.driver.createSchemaBuilder = vi.fn().mockReturnValue({
      log: vi.fn().mockResolvedValue({ upQueries: [], downQueries: [] }),
    });

    await generateMigration("no_change_migration");

    expect(CommandUtils.createFile).not.toHaveBeenCalled();
    expect(mockApp.close).toHaveBeenCalled();
  });

  it("should handle error during generation and throw", async () => {
    mockDatabaseService.source.driver.createSchemaBuilder = vi.fn().mockReturnValue({
      log: vi.fn().mockRejectedValue(new Error("Schema builder failure")),
    });

    await expect(generateMigration("faulty_migration")).rejects.toThrow("Schema builder failure");
    expect(mockApp.close).toHaveBeenCalled();
  });
});
