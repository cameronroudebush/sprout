import { setupTests } from "@backend/test/helpers";
setupTests();

import { AppModule } from "@backend/app.module";
import { SproutLogger } from "@backend/core/logger";
import { configureApiDocument } from "@backend/core/openapi";
import { generateOpenApiSpec } from "@backend/scripts/generate.api-spec";
import { NestFactory } from "@nestjs/core";
import { SwaggerModule } from "@nestjs/swagger";
import * as fs from "fs";
import path from "path";
import prettier from "prettier";

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

vi.mock("@nestjs/swagger", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@nestjs/swagger")>();
  return {
    ...actual,
    SwaggerModule: {
      ...actual.SwaggerModule,
      createDocument: vi.fn(),
    },
  };
});

vi.mock("@backend/core/openapi", () => ({
  configureApiDocument: vi.fn(),
}));

vi.mock("fs", () => ({
  default: {
    statSync: vi.fn(),
    writeFileSync: vi.fn(),
  },
  statSync: vi.fn(),
  writeFileSync: vi.fn(),
}));

vi.mock("prettier", () => ({
  default: {
    format: vi.fn().mockResolvedValue('{\n  "openapi": "3.0.0"\n}'),
  },
}));

describe("generateOpenApiSpec", () => {
  let mockApp: { close: ReturnType<typeof vi.fn> };
  let originalArgv: string[];

  beforeEach(() => {
    vi.clearAllMocks();
    originalArgv = [...process.argv];

    mockApp = {
      close: vi.fn().mockResolvedValue(undefined),
    };

    vi.mocked(NestFactory.create).mockResolvedValue(mockApp as any);
    vi.mocked(configureApiDocument).mockReturnValue({} as any);
    vi.mocked(SwaggerModule.createDocument).mockReturnValue({ openapi: "3.0.0" } as any);
    vi.mocked(prettier.format).mockResolvedValue('{\n  "openapi": "3.0.0"\n}');
  });

  afterEach(() => {
    process.argv = originalArgv;
  });

  it("should generate openapi spec and write formatted JSON to specified path", async () => {
    vi.mocked(fs.statSync).mockReturnValue({
      isDirectory: () => false,
    } as any);

    const targetPath = "./custom-spec.json";
    await generateOpenApiSpec(targetPath);

    expect(NestFactory.create).toHaveBeenCalledWith(AppModule, {
      logger: expect.any(SproutLogger),
    });
    expect(configureApiDocument).toHaveBeenCalledWith(mockApp);
    expect(SwaggerModule.createDocument).toHaveBeenCalledWith(mockApp, {});
    expect(fs.statSync).toHaveBeenCalledWith(path.resolve(targetPath));
    expect(prettier.format).toHaveBeenCalled();
    expect(fs.writeFileSync).toHaveBeenCalledWith(path.resolve(targetPath), '{\n  "openapi": "3.0.0"\n}');
    expect(mockApp.close).toHaveBeenCalled();
  });

  it("should use process.argv[2] as fallback path when givenPath is not explicitly provided", async () => {
    process.argv = ["node", "script.js", "./argv-spec.json"];
    vi.mocked(fs.statSync).mockReturnValue({
      isDirectory: () => false,
    } as any);

    await generateOpenApiSpec(undefined);

    expect(fs.statSync).toHaveBeenCalledWith(path.resolve("./argv-spec.json"));
    expect(fs.writeFileSync).toHaveBeenCalledWith(path.resolve("./argv-spec.json"), '{\n  "openapi": "3.0.0"\n}');
    expect(mockApp.close).toHaveBeenCalled();
  });

  it("should default to ./openapi-spec.json when givenPath and process.argv[2] are omitted", async () => {
    process.argv = ["node", "script.js"];
    vi.mocked(fs.statSync).mockReturnValue({
      isDirectory: () => false,
    } as any);

    await generateOpenApiSpec(undefined);

    expect(fs.statSync).toHaveBeenCalledWith(path.resolve("./openapi-spec.json"));
    expect(fs.writeFileSync).toHaveBeenCalledWith(path.resolve("./openapi-spec.json"), '{\n  "openapi": "3.0.0"\n}');
    expect(mockApp.close).toHaveBeenCalled();
  });

  it("should throw an error if the output path is a directory", async () => {
    vi.mocked(fs.statSync).mockReturnValue({
      isDirectory: () => true,
    } as any);

    await expect(generateOpenApiSpec("./output-dir")).rejects.toThrow("Output path is a directory. Refusing to write.");
    expect(fs.writeFileSync).not.toHaveBeenCalled();
    expect(mockApp.close).not.toHaveBeenCalled();
  });
});
