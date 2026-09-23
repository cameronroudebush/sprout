import { setupTests } from "@backend/test/helpers";
setupTests();

import { AppModule } from "@backend/app.module";
import { SproutLogger } from "@backend/core/logger";
import { DatabaseService } from "@backend/database/database.service";
import { generateMigration } from "@backend/scripts/generate.migration";
import { NestFactory } from "@nestjs/core";
import prettier from "prettier";
import { CommandUtils } from "typeorm/commands/CommandUtils.js";
import { MigrationGenerateCommand } from "typeorm/commands/MigrationGenerateCommand.js";

vi.mock("@nestjs/core", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@nestjs/core")>();
  return {
    ...actual,
    NestFactory: {
      ...actual.NestFactory,
      create: vi.fn(),
    },
  };
});

vi.mock("prettier", () => ({
  default: {
    format: vi.fn().mockResolvedValue("export class TestMigration {}"),
  },
}));

vi.mock("typeorm/commands/CommandUtils.js", () => ({
  CommandUtils: {
    createFile: vi.fn().mockResolvedValue(undefined),
  },
}));

vi.mock("typeorm/commands/MigrationGenerateCommand.js", () => ({
  MigrationGenerateCommand: {
    getTemplate: vi.fn().mockReturnValue("raw-template-content"),
  },
}));

describe("generateMigration", () => {
  let mockApp: any;
  let mockDatabaseService: any;
  let mockSource: any;

  beforeEach(() => {
    vi.clearAllMocks();

    mockSource = {
      isInitialized: false,
      initialize: vi.fn().mockResolvedValue(true),
      driver: {
        createSchemaBuilder: vi.fn().mockReturnValue({
          log: vi.fn().mockResolvedValue({
            upQueries: [
              { query: "CREATE TABLE `user` (`id` varchar)", parameters: [] },
              { query: "INSERT INTO `user` VALUES (?)", parameters: ["admin"] },
            ],
            downQueries: [
              { query: "DROP TABLE `user`", parameters: ["admin"] },
              { query: "DROP INDEX `user_idx`", parameters: [] },
            ],
          }),
        }),
      },
    };

    mockDatabaseService = {
      source: mockSource,
      setSQLitePRAGMA: vi.fn().mockResolvedValue(undefined),
    };

    mockApp = {
      get: vi.fn().mockReturnValue(mockDatabaseService),
      close: vi.fn().mockResolvedValue(undefined),
    };

    vi.mocked(NestFactory.create).mockResolvedValue(mockApp as any);
  });

  it("should generate and write migration file when schema changes are found", async () => {
    await generateMigration("add_user_table");

    expect(NestFactory.create).toHaveBeenCalledWith(AppModule, {
      logger: expect.any(SproutLogger),
    });
    expect(mockApp.get).toHaveBeenCalledWith(DatabaseService);

    expect(mockDatabaseService.setSQLitePRAGMA).toHaveBeenCalledWith(false);

    expect(MigrationGenerateCommand.getTemplate).toHaveBeenCalledWith(
      expect.stringMatching(/^Add_user_table\d+$/),
      expect.any(Number),
      [
        "        await queryRunner.query(`CREATE TABLE \\`user\\` (\\`id\\` varchar)`);",
        '        await queryRunner.query(`INSERT INTO \\`user\\` VALUES (?)`, ["admin"]);',
      ],
      ["        await queryRunner.query(`DROP INDEX \\`user_idx\\``);", '        await queryRunner.query(`DROP TABLE \\`user\\``, ["admin"]);'],
    );

    expect(prettier.format).toHaveBeenCalledWith("raw-template-content", expect.objectContaining({ parser: "typescript" }));
    expect(CommandUtils.createFile).toHaveBeenCalledWith(
      expect.stringMatching(/src[/\\]database[/\\]migration[/\\]sqlite[/\\]\d+-add_user_table\.ts$/),
      "export class TestMigration {}",
    );
    expect(mockApp.close).toHaveBeenCalled();
  });

  it("should skip initialization step if database source is already initialized", async () => {
    mockSource.isInitialized = true;

    await generateMigration("test_init");

    expect(mockSource.driver.createSchemaBuilder).toHaveBeenCalled();
    expect(mockApp.close).toHaveBeenCalled();
  });

  it("should log message and exit early if no schema changes are detected", async () => {
    mockSource.driver.createSchemaBuilder.mockReturnValue({
      log: vi.fn().mockResolvedValue({
        upQueries: [],
        downQueries: [],
      }),
    });

    await generateMigration("no_change_migration");

    expect(CommandUtils.createFile).not.toHaveBeenCalled();
    expect(mockApp.close).toHaveBeenCalled();
  });

  it("should catch, log, and rethrow error if migration generation fails", async () => {
    const error = new Error("Database connection lost");
    mockSource.driver.createSchemaBuilder().log.mockRejectedValue(error);

    await expect(generateMigration("failing_migration")).rejects.toThrow("Database connection lost");
    expect(mockApp.close).toHaveBeenCalled();
  });
});
