# Native ESM & Vitest Migration Guide

This document summarizes the migration of the Sprout NestJS backend project to native ES Modules (ESM) and the test runner transition from Jest to Vitest.

---

## 1. Package & TypeScript Configuration Changes

### `package.json` Updates (`backend/package.json`)

- **ESM Module Declaration**: Added `"type": "module"` to `backend/package.json` to designate all `.js` files within the package as ES modules.
- **Dependency Changes**:
    - **Removed**: `jest`, `@types/jest`, `ts-jest`, `jest-junit`, `babel-jest`.
    - **Added**: `vitest`, `@vitest/coverage-v8`, `vite-tsconfig-paths`, `unplugin-swc`.
- **Test Scripts**:
    - `npm run test`: `vitest run`
    - `npm run test:watch`: `vitest`
    - `npm run test:watch:cov`: `vitest --coverage`
    - `npm run test:cov`: `vitest run --coverage`

### `tsconfig.json` & `tsconfig.base.json` Updates (`backend/tsconfig.json`)

- **Module Target**: Updated `"module"` and `"moduleResolution"` to `"NodeNext"` in `backend/tsconfig.base.json`.
- **Type Definitions**: Updated `"types"` in `backend/tsconfig.json` from `["node", "jest"]` to `["node", "vitest/globals"]`.
- **Path Aliases**: Preserved `@backend/*` path alias mapping (`"./src/*"`) for clean absolute imports.

---

## 2. Relative Import Formatting Rules

Under Node.js native ESM (`"type": "module"` with `"moduleResolution": "NodeNext"`):

- **Relative Imports**: All relative import and export specifiers pointing to local files must explicitly include the `.js` file extension (or `/index.js` for directory imports).

    ```typescript
    // Correct ESM format:
    import { AppService } from "./app.service.js";
    import { User } from "../user/model/user.model.js";

    // Incorrect (CommonJS style):
    import { AppService } from "./app.service";
    ```

- **Package & Alias Imports**: Imports from `node_modules` (e.g. `@nestjs/common`) and path alias imports (e.g. `@backend/config/core`) do not require relative file extensions.

---

## 3. Vitest Test Runner & Mocking (`vi` Object)

### Vitest Configuration (`backend/vitest.config.mts`)

A new Vitest configuration file `backend/vitest.config.mts` was created using `unplugin-swc` for NestJS decorator metadata support and `vite-tsconfig-paths` for path alias resolution:

```typescript
import { defineConfig } from "vitest/config";
import tsconfigPaths from "vite-tsconfig-paths";
import swc from "unplugin-swc";

export default defineConfig({
    test: {
        globals: true,
        environment: "node",
        include: ["src/**/*.spec.ts"],
        coverage: {
            provider: "v8",
            reporter: ["text", "json-summary", "html"],
        },
    },
    plugins: [
        tsconfigPaths(),
        swc.vite({
            module: { type: "es6" },
        }),
    ],
});
```

### Mocking API (`vi` Object)

All test suites were refactored from Jest's global `jest` object to Vitest's `vi` object:

- **Function Mocks**: `jest.fn()` → `vi.fn()`
- **Module Mocks**: `jest.mock()` → `vi.mock()`
- **Spies**: `jest.spyOn()` → `vi.spyOn()`
- **Mock Clearing**: `jest.clearAllMocks()` → `vi.clearAllMocks()`
- **Fake Timers**: `jest.useFakeTimers()` → `vi.useFakeTimers()`, `jest.advanceTimersByTime()` → `vi.advanceTimersByTime()`

---

## 4. TypeORM CLI & Packaging Pipeline Updates

### TypeORM CLI Migration Script

In `backend/package.json`, the `migrate` script was updated to execute TypeORM CLI migration generation within an ESM runtime environment using `typeorm-ts-node-esm`:

```json
"migrate": "cross-var typeorm-ts-node-esm migration:generate -d ./src/scripts/generate.migration.ts ./src/database/migration/sqlite/$npm_config_name"
```

### Build & Binary Compilation Pipeline (`pkg`)

The production build script in `backend/package.json` uses NestJS CLI with Rspack/Webpack bundling prior to packaging with `@yao-pkg/pkg`:

```json
"build": "cross-env NODE_ENV=prod nest build --builder rspack && pkg package.json"
```

This ensures that the TypeScript code and decorator metadata are compiled into a bundled standalone CommonJS executable distribution, preventing raw ESM module resolution issues when bundled into binary executables with `@yao-pkg/pkg`.
