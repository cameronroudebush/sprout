# Instructions for AI Agents Working on Sprout

## Backend Testing & Coverage Guidelines

When generating or extending unit tests in the `/backend` package:

1. **Test Execution:**
    - Run backend unit tests: `npm run test --prefix backend`
    - Run backend test coverage: `npm run test:cov --prefix backend`
    - Run specific backend test files: `npm run test --prefix backend -- backend/src/path/to/target.spec.ts`

2. **Coverage Goal:**
    - Target 100% line, statement, function, and branch coverage for any new or updated unit test suites in `/backend`.

3. **Centralized Test Entities:**
    - Always use centralized test entities from `@backend/test/entities` (`TestEntities`) whenever creating model or entity mock data in test files (`TestEntities.user`, `TestEntities.adminUser`, `TestEntities.userConfig`, `TestEntities.account`, `TestEntities.institution`, etc.) so model definitions are unified in a single location and easy to maintain.

4. **Writing Unit Tests:**
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

5. **Code Style & Formatting:**
    - Always run `npm run prettier:write` after creating or modifying code or test files.

## Documentation Structure & Formatting Guidelines

When writing, updating, or reorganizing documentation under `/docs`:

1. **Frontmatter Standards:**
    - Every Markdown file in `docs/` should start with valid YAML frontmatter specifying `title` and `description`.
    - If navigation elements or table of contents need to be hidden, use valid syntax under `hide:` (e.g. `hide:\n  - navigation\n  - toc`). Do not leave `hide:` empty.

2. **Heading Hierarchy:**
    - Use a single level-1 heading (`# Page Title`) per document.
    - Organize sub-sections using level-2 (`## Section`) and level-3 (`### Sub-section`) headings sequentially. Avoid skipping heading levels.

3. **MkDocs Material Admonitions:**
    - Use standard MkDocs Material admonition blocks for important tips, notes, warnings, or security warnings:

        ```markdown
        !!! note "Optional Configuration"
        Content goes here.

        !!! warning "Security Warning"
        Content goes here.
        ```

    - Ensure indented code blocks or lists inside admonitions are indented properly (4 spaces per level) so MkDocs renders them cleanly.

4. **Environment Variables & Configuration Standards:**
    - All environment variable references must strictly match application runtime keys (prefixed with `sprout_` and using underscores for nested YAML properties, e.g., `sprout_server_publicUrl`).
    - Present environment variables using formatted Markdown tables with clear column headers: `Variable`, `Required`, `Default`, and `Description`.

5. **Code Snippets & Command Examples:**
    - Specify exact syntax highlighting tags for code blocks (`yaml title="..." linenums="1"`, `bash`, `powershell`, `sql`, `typescript`).
    - Ensure command examples and sample code snippets are clear, self-contained, and tested.

6. **Usability & Onboarding:**
    - Include explicit **Prerequisites** and **Step-by-Step** instructions for new users setting up features.
    - Provide relative Markdown links (`[Configuration](./configuration.md)`) when referencing other documentation pages and verify all relative links resolve correctly.

7. **Doc Formatting & Validation:**
    - Validate Markdown and code formatting by running `npm run prettier:write`.
    - Verify that documentation builds cleanly without syntax errors using `python3 -m mkdocs build` (or `npm run docs:serve` via Docker).
