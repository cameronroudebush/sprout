import swc from "unplugin-swc";
import { defineConfig } from "vitest/config";
import path from "node:path";

export default defineConfig({
  resolve: {
    alias: {
      "@backend/metadata.js": path.resolve(import.meta.dirname, "src/test/openapi-metadata.mock.ts"),
    },
    tsconfigPaths: true,
  },
  test: {
    globals: true,
    environment: "node",
    include: ["src/**/*.spec.ts"],

    // Test execution report outputs
    reporters: ["default", "junit"],
    outputFile: {
      junit: "./coverage/junit.xml",
      json: "./coverage/report.json",
    },

    coverage: {
      reportOnFailure: true,
      include: ["src/**/*.ts", "openapi-metadata.plugin.mjs"],
      exclude: ["src/**/migration/**/*.ts", "src/**/*.d.ts", "src/types/**/*.ts", "src/test/**/*"],
      clean: false,
      cleanOnRerun: false,
      provider: "v8",
      reporter: ["text", "json", "json-summary", "html", "clover", "cobertura"],
      // Set output directory for all coverage reports (defaults to './coverage')
      reportsDirectory: "./coverage",
    },
  },
  plugins: [
    swc.vite({
      module: { type: "es6" },
    }),
  ],
});
