---
title: Testing Guide & Best Practices
description: Guidelines for writing unit tests and generating test cases for Sprout backend.
hide:
    - footer
---

# Testing Guide & Best Practices

This document provides instructions and guidelines for developers and automated AI agents generating unit tests for the Sprout backend codebase (`/backend`).

## Running Tests

From the repository root, run the following commands:

```bash
# Run all backend tests
npm run test --prefix backend

# Run backend tests with code coverage report
npm run test:cov --prefix backend

# Run a specific test suite
npm run test --prefix backend -- backend/src/path/to/target.spec.ts
```

## Target: 100% Line Coverage

When adding unit tests for backend services, controllers, guards, or models, aim for **100% line coverage** across all statements, branches, and functions.

### Best Practices & Patterns

1. **Test File Naming & Location:**
   Place test files adjacent to the implementation file being tested with `.spec.ts` suffix.
    - Example: `src/user/user.service.ts` -> `src/user/user.service.spec.ts`

2. **Test Setup Helper:**
   Always invoke `setupTests()` at the top of test files before importing NestJS modules or application entities:

    ```typescript
    import { setupTests } from "@backend/test/helpers";
    setupTests();
    ```

3. **Module Imports:**
   Use NestJS absolute import paths starting with `@backend/`:

    ```typescript
    import { SSEService } from "@backend/sse/sse.service";
    import { User } from "@backend/user/model/user.model";
    ```

4. **Mocking Configuration & Global State:**
    - For `Configuration` properties (e.g. `Configuration.server.auth`), capture the original value and restore it in `afterEach()` to prevent test leakage:
        ```typescript
        const originalAuth = Configuration.server.auth;
        afterEach(() => {
            Configuration.server.auth = originalAuth;
        });
        ```

5. **Entity & Static Method Mocking:**
    - Use `jest.spyOn()` for static model methods (e.g. `User.count()`, `Institution.find()`).
    - Use `jest.clearAllMocks()` in `beforeEach()` to ensure strict test isolation.

6. **Error Testing:**
    - Use `.rejects.toThrow()` for asynchronous error testing:
        ```typescript
        await expect(service.deleteUser(user, false)).rejects.toThrow(InternalServerErrorException);
        ```
