# Instructions for AI Agents Working on Sprout

## Backend Testing & Coverage Guidelines

When generating or extending unit tests in the `/backend` package:

1. **Test Execution:**
    - Run backend unit tests: `npm run test --prefix backend`
    - Run backend test coverage: `npm run test:cov --prefix backend`
    - Run specific backend test files: `npm run test --prefix backend -- backend/src/path/to/target.spec.ts`

2. **Coverage Goal:**
    - Target 100% line, statement, function, and branch coverage for any new or updated unit test suites in `/backend`.

3. **Writing Unit Tests:**
    - Always invoke `setupTests()` from `@backend/test/helpers` at the top of each test file before importing NestJS modules or application entities:
        ```typescript
        import { setupTests } from "@backend/test/helpers";
        setupTests();
        ```
    - Use NestJS absolute path aliases starting with `@backend/`.
    - Use `jest.clearAllMocks()` in `beforeEach()` to ensure strict test isolation.
    - For static properties or global state modified in tests (e.g. `Configuration.server.auth`, `Configuration.isDevBuild`), always capture original values and restore them in `afterEach()` to avoid test pollution across runs.
    - Use `jest.spyOn()` for static model/entity methods (e.g. `User.count()`, `Institution.find()`).
    - Use `.rejects.toThrow()` for asynchronous error assertions.

4. **Code Style & Formatting:**
    - Always run `npm run prettier:write` after creating or modifying code or test files.
