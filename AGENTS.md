# Instructions for AI Agents Working on Sprout

## Project Overview

Sprout is a full-stack personal finance management application that aggregates financial data (account balances, transactions, stock holdings, property values) via external financial aggregators and presents daily snapshots, cash flow metrics, net worth tracking, and AI-driven insights to users.

### High-Level Architecture

The repository is structured as a monorepo containing:

- **`backend/`**: NestJS application written in TypeScript using TypeORM with SQLite. Handles API requests, background job processing (BullMQ), provider sync (Plaid, SimpleFin, SnapTrade, Zillow, Coinbase), Server-Sent Events (SSE), and Gemini AI integration.
- **`frontend/`**: Cross-platform application built with Flutter (Dart). Handles mobile (Android/iOS) and web client interfaces, utilizing Riverpod for state management, GoRouter for navigation, and an auto-generated OpenAPI client for backend communication.
- **`scripts/`**: Utility scripts for Docker builds, automated screenshots, and tooling.
- **`docs/`**: Documentation, OpenAPI specifications (`openapi-spec.json`), and MkDocs configuration.

---

## Repository & File Structure

```
sprout/
├── backend/                  # NestJS TypeScript backend API
│   ├── src/                  # Backend application source code
│   │   ├── account/          # Account management (bank accounts, balances)
│   │   ├── auth/             # Authentication, JWT strategies, OIDC, auth guards
│   │   ├── cash-flow/        # Income vs expense calculation & forecasting
│   │   ├── category/         # Transaction categories and rules
│   │   ├── chat/             # AI chat agent integration (Google Gemini)
│   │   ├── config/           # App configuration settings and guards
│   │   ├── core/             # Shared core services, decorators, middleware, jobs
│   │   ├── database/         # TypeORM entities, SQLite migrations, transformers
│   │   ├── demo/             # Seed data and demo mode utilities
│   │   ├── email/            # Email notification services (Nodemailer, templates)
│   │   ├── holding/          # Investment holdings and portfolio tracking
│   │   ├── institution/      # Financial institutions (banks, brokerages)
│   │   ├── net-worth/        # Net worth history and calculations
│   │   ├── notification/     # In-app and push notification system (Firebase Cloud Messaging)
│   │   ├── providers/        # External aggregator connectors (Plaid, SimpleFin, SnapTrade, Zillow, Coinbase)
│   │   ├── scripts/          # Backend CLI scripts and database tooling
│   │   ├── sse/              # Server-Sent Events management for real-time update streaming
│   │   ├── test/             # Centralized test helpers (`setupTests`) and mock entities (`TestEntities`)
│   │   ├── transaction/      # Financial transaction management and batch jobs
│   │   └── user/             # User profile, credentials, and settings management
│   ├── test/                 # E2E / integration tests setup
│   ├── nest-cli.json         # NestJS CLI configuration
│   ├── package.json          # Backend Node.js dependencies and scripts
│   └── tsconfig.json         # TypeScript configuration (supports `@backend/` path alias)
│
├── frontend/                 # Flutter Dart cross-platform mobile & web app
│   ├── lib/                  # Dart application source code
│   │   ├── account/          # Account UI screens, widgets, and state providers
│   │   ├── api/              # Auto-generated OpenAPI Dart client code
│   │   ├── auth/             # Login, registration, and session UI
│   │   ├── cash-flow/        # Cash flow breakdown graphs and view models
│   │   ├── category/         # Category management views and pickers
│   │   ├── chat/             # AI Assistant chat widget and models
│   │   ├── config/           # App settings UI (server connection, security settings)
│   │   ├── holding/          # Investment portfolio display widgets
│   │   ├── institution/      # Institution linking UI
│   │   ├── main.dart         # Flutter application entry point
│   │   ├── net-worth/        # Net worth charts and summary widgets
│   │   ├── notification/     # Notification center widgets
│   │   ├── provider/         # Provider connection widgets (Plaid Link, SimpleFin setup, etc.)
│   │   ├── routes/           # Routing configuration using `go_router`
│   │   ├── setup/            # Initial app onboarding / setup wizard
│   │   ├── shared/           # Common UI components, API wrappers, dialogs, auth helpers
│   │   ├── theme/            # Styling, themes, and FlexColorScheme setup
│   │   ├── transaction/      # Transaction lists, filtering, detail dialogs
│   │   └── user/             # Profile management UI
│   ├── pubspec.yaml          # Flutter package dependencies and configuration
│   └── assets/               # Branding assets, icons, and fonts
│
├── docs/                     # Project documentation & OpenAPI specs (`assets/openapi-spec.json`)
├── scripts/                  # Docker build and screenshot automation scripts
├── dockerfile                # Multi-stage production Dockerfile
├── nginx.conf                # Web server configuration for serving frontend & proxying API
└── package.json              # Root package configuration & project-wide scripts
```

---

## Authentication Architecture (`backend/src/auth/`)

Sprout supports dual authentication mechanisms managed via Passport NestJS strategies:

1. **Local Authentication**:
    - Username/password authentication backed by bcrypt hashing.
    - Generates signed JWT access tokens returned to clients or attached as HTTP-only cookies (`auth_token`).

2. **OpenID Connect (OIDC / Single Sign-On)**:
    - OAuth2 / OIDC authorization code flow integrated via `OIDCStrategy` (`auth/strategy/oidc.strategy.ts`).
    - Supports auto-discovery endpoint fetching, token exchange, and optional token introspection (`auth/model/oidc.introspection.ts`).

3. **Token Extraction & Extractors**:
    - Custom extractor (`auth/strategy/auth.extractor.ts`) parses authentication tokens sequentially from HTTP-only `auth_token` cookies or standard `Authorization: Bearer <token>` headers.

4. **Guards & Authorization**:
    - `AuthGuard` (`auth/guard/auth.guard.ts`): Protects routes requiring valid JWT sessions. Can be disabled dynamically when authentication is disabled in server config.
    - `AdminGuard` (`auth/guard/admin.guard.ts`): Restricts administrative routes to users with `isAdmin: true`.
    - `StrategyGuard` (`auth/guard/strategy.guard.ts`): Validates active authentication strategy configurations before executing strategy-specific handlers.

---

## Backend Code Structure & Conventions

The backend follows modular NestJS architecture patterns across features:

### 1. Controllers (`*.controller.ts`)

- Handle API HTTP request routing, path parameters, query params, and responses.
- Decorated with `@Controller('<route>')`, `@UseGuards(...)`, and NestJS Swagger decorators (`@ApiOperation`, `@ApiResponse`, `@ApiTags`).
- Delegate business processing immediately to corresponding Services.

### 2. Services (`*.service.ts`)

- Encapsulate business logic, database queries via TypeORM models/repositories, external API calls, and calculations.
- Declared as `@Injectable()` providers and injected into controllers or job processors.

### 3. Background Jobs & Queues (`/jobs/`)

- Asynchronous and scheduled task execution managed using BullMQ over Redis.
- Extend standardized base classes in `core/jobs/`:
    - `JobBase`: Abstract base class providing common queue initialization, logging, error handling, and job lifecycle hooks.
    - `JobDistributedBase`: Extends `JobBase` with distributed locking semantics (using Redis key locks) to ensure single-instance execution across multi-replica deployments.

### 4. Models & DTOs (`/model/`)

- **API DTOs** (`model/api/*.dto.ts`): Request/response payload contracts annotated with `class-validator` (`@IsString()`, `@IsOptional()`, `@ValidateNested()`) and `class-transformer` (`@Type()`).
- **Domain Models & Entities**: Database models subclassing TypeORM `BaseEntity` or custom entities located in `database/model/`.

### 5. Aggregator Provider Architecture (`backend/src/providers/`)

- All financial aggregator implementations (Plaid, SimpleFin, SnapTrade, Zillow, Coinbase) inherit from abstract base connectors (`providers/base/core.ts`) and register with `SyncService`.
- Unified data transformation mapping external accounts, transactions, and holdings into Sprout's internal TypeORM domain models.

---

## Frontend Architecture & Conventions (`frontend/lib/`)

### Tech Stack & Architecture

- **Framework**: Flutter (Dart) targeting Web, Android, and iOS.
- **State Management**: `flutter_riverpod` (Riverpod 3.x) using `riverpod_annotation` code generation.
- **Navigation**: `go_router` for route definition, query params, and deep linking.
- **Data Visualization**: `fl_chart` for net worth graphs, cash flow trends, and investment breakdowns.
- **Styling**: `flex_color_scheme` for unified light/dark mode design.
- **API Communication**: Auto-generated Dart HTTP client from backend OpenAPI specification located in `lib/api/`.

### Modular Organization

Feature packages (`account`, `transaction`, `net-worth`, `cash-flow`, `holding`, `chat`, etc.) follow a consistent component layout:

- `models/`: Client-side domain models and JSON serialization logic.
- `widgets/`: Pure UI components, view layouts, filter drawers, and modal dialogs.
- **Riverpod Providers**: Reactive providers managing network calls to backend APIs, caching, and local UI state changes.

---

## Developer Workflows & Commands

### Project Setup

To install all dependencies across root and backend projects:

```bash
npm run install:all
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
        import { setupTests } from "@backend/test/helpers";
        setupTests();
        ```
    - Use NestJS absolute path aliases starting with `@backend/`.
    - Use `jest.clearAllMocks()` in `beforeEach()` to ensure strict test isolation.
    - For static properties or global state modified in tests (e.g. `Configuration.server.auth`), capture original values and restore them in `afterEach()`.
    - Use `jest.spyOn()` for static model methods.
    - Use `.rejects.toThrow()` for asynchronous error assertions.

### OpenAPI Client Generation

To re-generate the Dart API client for the frontend after changing backend controllers or DTOs:

1. Export the OpenAPI specification:
    ```bash
    npm run export:api:spec --prefix backend
    ```
2. Generate the Dart code:
    ```bash
    npm run api:generate:dart
    ```

### Code Formatting & Quality

- Format all files across the project:
    ```bash
    npm run prettier:write
    ```
- Check formatting without modifying:
    ```bash
    npm run prettier:check
    ```
