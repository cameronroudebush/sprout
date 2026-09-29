import { PluginMetadataGenerator } from "@nestjs/cli/lib/compiler/plugins/plugin-metadata-generator.js";
import { ReadonlyVisitor } from "@nestjs/swagger/plugin";
import path from "node:path";

const PLUGIN_NAME = "OpenApiMetadataPlugin";

/** Supplies Nest Swagger's type-derived metadata to builds transpiled with SWC. */
export class OpenApiMetadataPlugin {
  constructor({ sourceRoot, tsconfigPath }) {
    this.sourceRoot = path.resolve(sourceRoot);
    this.metadataFile = path.join(this.sourceRoot, "metadata.ts");
    this.tsconfigPath = path.resolve(tsconfigPath);
  }

  apply(compiler) {
    let hasGeneratedMetadata = false;

    // Generate before the first module resolution so the generated import exists on clean checkouts.
    compiler.hooks.beforeCompile.tap(PLUGIN_NAME, () => {
      if (!hasGeneratedMetadata) {
        this.generateMetadata();
        hasGeneratedMetadata = true;
      }
    });

    // Refresh metadata before watch rebuilds when application TypeScript changes.
    compiler.hooks.watchRun.tap(PLUGIN_NAME, (watchingCompiler) => {
      const changedFiles = [...(watchingCompiler.modifiedFiles ?? []), ...(watchingCompiler.removedFiles ?? [])];
      const sourceChanged = changedFiles.some((file) => {
        const absolutePath = path.resolve(file);
        const relativePath = path.relative(this.sourceRoot, absolutePath);
        const isInSourceRoot = relativePath !== "" && relativePath !== ".." && !relativePath.startsWith(`..${path.sep}`) && !path.isAbsolute(relativePath);

        // Ignore generated output to avoid rebuild loops, and test files which are excluded from the build.
        return isInSourceRoot && absolutePath !== this.metadataFile && relativePath.endsWith(".ts") && !relativePath.endsWith(".spec.ts");
      });

      if (sourceChanged) {
        this.generateMetadata();
        hasGeneratedMetadata = true;
      }
    });
  }

  /** TypeScript AST pass supplies DTO and controller metadata that SWC cannot infer after erasing types. */
  generateMetadata() {
    const program = ReadonlyVisitor.createTsProgram(this.tsconfigPath);
    new PluginMetadataGenerator().generate({
      visitors: [
        new ReadonlyVisitor({
          controllerFileNameSuffix: [".controller.ts"],
          dtoFileNameSuffix: [".dto.ts", ".model.ts", ".type.ts"],
          introspectComments: true,
          pathToSource: this.sourceRoot,
        }),
      ],
      outputDir: this.sourceRoot,
      tsProgramRef: program,
    });
  }
}
