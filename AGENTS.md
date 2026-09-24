# Instructions for AI Agents Working on Sprout

## Project Guidance

Sprout is a full-stack personal finance application. Use these canonical references instead of duplicating architecture or design details here:

- [System architecture and repository layout](docs/developer/architecture.md)
- [UI and design guidelines](docs/developer/design.md)

Keep this file focused on agent-specific constraints, workflows, and validation commands. Update the referenced documents when architecture or design guidance changes.

---

## Developer Workflows & Commands

### Project Setup

To install all dependencies across root and backend projects:

```bash
npm run install:all
```

### Production Build

To compile the backend production build and binary executable:

```bash
npm run build --prefix backend
```

### Backend Testing & Coverage Guidelines

When working with backend unit tests:

1. **Execution**:
    - Run unit tests: `npm run test --prefix backend`
    - Run unit tests with coverage: `npm run test:cov --prefix backend`
    - Run single test file: `npm run test --prefix backend -- backend/src/path/to/target.spec.ts`

2. **Coverage Standard**:
    - Target 100% line, statement, function, and branch coverage for any new or updated unit test suites in `/backend`.

3. **Centralized Test Entities**:
    - Always use centralized test entities from `@backend/test/entities` (`TestEntities`) whenever creating model or entity mock data in test files (`TestEntities.user`, `TestEntities.adminUser`, `TestEntities.userConfig`, `TestEntities.account`, `TestEntities.institution`, etc.).

4. **Writing Backend Unit Tests**:
    - Always invoke `setupTests()` from `@backend/test/helpers` at the top of each test file before importing NestJS modules or application entities:
        ```typescript
        import { setupTests } from "@backend/test/helpers.js";
        setupTests();
        ```
    - Use NestJS absolute path aliases starting with `@backend/`.
    - Use `vi.clearAllMocks()` in `beforeEach()` to ensure strict test isolation.
    - For static properties or global state modified in tests (e.g. `Configuration.server.auth`), capture original values and restore them in `afterEach()`.
    - Use `vi.spyOn()` for static model methods.
    - Use `.rejects.toThrow()` for asynchronous error assertions.

### OpenAPI Client Generation

To re-generate the Dart API client for the frontend after changing backend controllers or DTOs:

1. Export the OpenAPI specification from the backend:
    ```bash
    npm run export:api:spec --prefix backend
    ```
2. Generate the Dart API client code from the repository root:
    ```bash
    npm run api:generate:dart
    ```

### Frontend Build & Verification

To verify and build the Flutter frontend client:

1. **Analyze / Format Check**:
    ```bash
    cd frontend && flutter analyze
    ```
2. **Build Web Output**:
    ```bash
    cd frontend && flutter build web
    ```
3. **Run Frontend Tests**:
    ```bash
    cd frontend && flutter test
    ```

### Database Migrations

To generate a database migration:

```bash
npm run migrate --prefix backend -- --name=MY-NAME-HERE
```

- **Note**: For PRs, you may only have one migration and it must be named relevantly.
- **Note**: Due to Webpack compilation, you need to restart the backend after running the migration command so it recognizes the newly generated migration file.

### Code Formatting & Quality

- Format all files across the project:
    ```bash
    npm run prettier:write
    ```
- Check formatting without modifying:
    ```bash
    npm run prettier:check
    ```

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
