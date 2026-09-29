import { setupTests } from "@backend/test/helpers.js";
setupTests();

import path from "node:path";

const mocks = vi.hoisted(() => ({
  createTsProgram: vi.fn(),
  generate: vi.fn(),
  readonlyVisitor: vi.fn(function (options) {
    return { options };
  }),
}));

vi.mock("@nestjs/cli/lib/compiler/plugins/plugin-metadata-generator.js", () => ({
  PluginMetadataGenerator: vi.fn(function () {
    return { generate: mocks.generate };
  }),
}));

vi.mock("@nestjs/swagger/plugin", () => ({
  ReadonlyVisitor: Object.assign(mocks.readonlyVisitor, { createTsProgram: mocks.createTsProgram }),
}));

import { OpenApiMetadataPlugin } from "../../openapi-metadata.plugin.mjs";

function createCompilerHarness() {
  let beforeCompileCallback: (() => void) | undefined;
  let watchRunCallback: ((watchingCompiler: { modifiedFiles?: Set<string>; removedFiles?: Set<string> }) => void) | undefined;

  const beforeCompileTap = vi.fn((_name: string, callback: () => void) => {
    beforeCompileCallback = callback;
  });
  const watchRunTap = vi.fn((_name: string, callback: typeof watchRunCallback) => {
    watchRunCallback = callback;
  });

  return {
    compiler: {
      hooks: {
        beforeCompile: { tap: beforeCompileTap },
        watchRun: { tap: watchRunTap },
      },
    },
    beforeCompileTap,
    watchRunTap,
    runBeforeCompile: () => beforeCompileCallback?.(),
    runWatchRunWithoutFileLists: () => watchRunCallback?.({}),
    runWatchRun: (modifiedFiles: string[] = [], removedFiles: string[] = []) =>
      watchRunCallback?.({ modifiedFiles: new Set(modifiedFiles), removedFiles: new Set(removedFiles) }),
  };
}

describe("OpenApiMetadataPlugin", () => {
  const sourceRoot = path.resolve("src");
  const tsconfigPath = path.resolve("tsconfig.build.json");
  const program = {};

  beforeEach(() => {
    vi.clearAllMocks();
    mocks.createTsProgram.mockReturnValue(program);
  });

  it("generates metadata once before first compile", () => {
    const plugin = new OpenApiMetadataPlugin({ sourceRoot, tsconfigPath });
    const harness = createCompilerHarness();

    plugin.apply(harness.compiler as any);

    expect(harness.beforeCompileTap).toHaveBeenCalledWith("OpenApiMetadataPlugin", expect.any(Function));
    expect(harness.watchRunTap).toHaveBeenCalledWith("OpenApiMetadataPlugin", expect.any(Function));
    harness.runBeforeCompile();
    harness.runBeforeCompile();

    expect(mocks.createTsProgram).toHaveBeenCalledOnce();
    expect(mocks.createTsProgram).toHaveBeenCalledWith(tsconfigPath);
    expect(mocks.readonlyVisitor).toHaveBeenCalledWith({
      controllerFileNameSuffix: [".controller.ts"],
      dtoFileNameSuffix: [".dto.ts", ".model.ts", ".type.ts"],
      introspectComments: true,
      pathToSource: sourceRoot,
    });
    expect(mocks.generate).toHaveBeenCalledOnce();
    expect(mocks.generate).toHaveBeenCalledWith({
      visitors: [{ options: expect.any(Object) }],
      outputDir: sourceRoot,
      tsProgramRef: program,
    });
  });

  it("regenerates metadata for modified and removed application TypeScript files", () => {
    const plugin = new OpenApiMetadataPlugin({ sourceRoot, tsconfigPath });
    const harness = createCompilerHarness();
    plugin.apply(harness.compiler as any);
    harness.runBeforeCompile();

    harness.runWatchRun([path.join(sourceRoot, "account", "account.controller.ts")]);
    harness.runWatchRun([], [path.join(sourceRoot, "account", "model", "account.type.ts")]);

    expect(mocks.generate).toHaveBeenCalledTimes(3);
  });

  it("ignores generated metadata, tests, non-TypeScript files, and paths outside source root", () => {
    const plugin = new OpenApiMetadataPlugin({ sourceRoot, tsconfigPath });
    const harness = createCompilerHarness();
    plugin.apply(harness.compiler as any);
    harness.runBeforeCompile();

    const excludedPaths = [
      path.join(sourceRoot, "metadata.ts"),
      path.join(sourceRoot, "account", "account.controller.spec.ts"),
      path.join(sourceRoot, "account", "account.controller.js"),
      path.resolve("generated.ts"),
      sourceRoot,
      path.dirname(sourceRoot),
      path.resolve(path.dirname(sourceRoot), "external.ts"),
    ];

    for (const file of excludedPaths) harness.runWatchRun([file]);
    harness.runWatchRun();
    harness.runWatchRunWithoutFileLists();

    expect(mocks.generate).toHaveBeenCalledOnce();
  });
});
