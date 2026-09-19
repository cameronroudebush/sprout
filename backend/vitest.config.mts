import swc from "unplugin-swc";
import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
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
      provider: "v8",
      reporter: ["text", "json-summary", "html", "clover", "cobertura"],
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
