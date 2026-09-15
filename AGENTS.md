# Instructions for AI Agents Working on Sprout

## Backend Testing Guidelines

When generating or extending unit tests in the `/backend` package:

1. **Test Execution:**
    - Run backend unit tests: `npm run test --prefix backend`
    - Run backend test coverage: `npm run test:cov --prefix backend`

2. **Coverage Goal:**
    - Strive for 100% line, statement, and branch coverage on targeted modules.

3. **Writing Unit Tests:**
    - Always call `setupTests()` from `@backend/test/helpers` at the beginning of each test file before other imports.
    - Use NestJS absolute path aliases starting with `@backend/`.
    - Ensure clean isolation by calling `jest.clearAllMocks()` in `beforeEach()`.
    - Restore global configuration states (e.g. `Configuration.server.auth`) after tests using `afterEach()`.

4. **Formatting:**
    - Always run `npm run prettier:write` after modifying or adding code or test files.
