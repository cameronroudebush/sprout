---
title: System Architecture Guide
description: Technical architecture, repository layout, data flow, and component breakdown for Sprout.
---

# Sprout Architecture & Layout Guide

This document provides a comprehensive overview of Sprout's software architecture, codebase layout, data flow, and backend/frontend subsystems. It serves as a guide for human developers and AI agents working on or extending the Sprout application.

---

## 1. System Overview & Monorepo Topology

Sprout is a self-hosted personal finance management platform designed to aggregate, track, and analyze financial data across multiple accounts, institutions, investment portfolios, and real estate holdings.

The project is structured as a monorepo with clear separation between the server-side backend API service and client frontend applications:

```
sprout/
├── backend/                  # NestJS TypeScript Backend API & Background Workers
├── frontend/                 # Flutter Cross-Platform Client (Web, Android, iOS)
├── docs/                     # MkDocs documentation site & OpenAPI specifications
├── scripts/                  # Docker build, screenshot generation, and CLI utilities
└── dockerfile                # Container definition for unified production deployment
```

```
                     +---------------------------------------+
                     |         Flutter Frontend Client       |
                     |  (Web / Android Mobile / iOS Mobile)  |
                     +-------------------+-------------------+
                                         |
                                         | REST API (HTTP) / SSE (Events)
                                         v
                     +-------------------+-------------------+
                     |           NestJS Backend API          |
                     |  (Controllers, Services, Guards)      |
                     +---------+-------------------+---------+
                               |                   |
            Async Jobs (BullMQ)|                   | TypeORM ORM
                               v                   v
                     +---------+---------+   +-----+---------+
                     | Redis / BullMQ    |   | SQLite DB     |
                     | Message Broker    |   | Storage       |
                     +---------+---------+   +---------------+
                               |
                               v
            +------------------+-------------------+
            |        Financial Aggregators          |
            | (Plaid, SimpleFin, SnapTrade, etc.)  |
            +--------------------------------------+
```

---

## 2. Repository Directory Structure

Below is the detailed directory structure for both backend and frontend codebases:

```
sprout/
├── backend/
│   ├── src/
│   │   ├── account/          # Account management (bank accounts, balances, credit limits)
│   │   ├── auth/             # Authentication, JWT, OIDC, password hashing, auth guards
│   │   ├── cash-flow/        # Income vs expense analysis, metrics, and forecasting
│   │   ├── category/         # Category taxonomy, transaction rules, and classification
│   │   ├── chat/             # Gemini AI chat agent interface & tool calling
│   │   ├── config/           # App configuration settings, environment resolution
│   │   ├── core/             # Cross-cutting concerns, decorators, base jobs, middleware
│   │   ├── database/         # TypeORM entities, migrations, and SQLite setup
│   │   ├── demo/             # Seed data and demo environment utilities
│   │   ├── email/            # Email notifications (Nodemailer, HTML templates)
│   │   ├── holding/          # Investment positions, stock holdings, crypto tracking
│   │   ├── institution/      # Financial institutions (banks, brokerages)
│   │   ├── net-worth/        # Daily net worth snapshots and historical charting
│   │   ├── notification/     # In-app notifications & Firebase Cloud Messaging (FCM)
│   │   ├── providers/        # Aggregator connectors (Plaid, SimpleFin, SnapTrade, Zillow, Coinbase)
│   │   ├── scripts/          # Backend CLI commands and database migrations
│   │   ├── sse/              # Server-Sent Events manager for live frontend updates
│   │   ├── test/             # Test helpers (`setupTests`) and mock entities (`TestEntities`)
│   │   ├── transaction/      # Financial transactions, batch importing, and rules
│   │   └── user/             # User accounts, settings, and profile management
│   ├── test/                 # Integration / E2E test suites
│   ├── nest-cli.json         # NestJS CLI configuration
│   ├── package.json          # Node.js dependencies & scripts
│   └── tsconfig.json         # TypeScript configuration (`@backend/` path alias)
│
├── frontend/
│   ├── android/              # Native Android wrapper and Home Screen Widget Java code
│   ├── ios/                  # Native iOS project setup
│   ├── lib/
│   │   ├── account/          # Bank/Investment account views & state providers
│   │   ├── api/              # Auto-generated Dart OpenAPI HTTP client
│   │   ├── auth/             # Login, register, OIDC redirect handlers
│   │   ├── cash-flow/        # Cash flow charts, trend analysis, monthly summaries
│   │   ├── category/         # Category selection, management, rule editing
│   │   ├── chat/             # AI Assistant chat sheet and conversation state
│   │   ├── config/           # Server settings, app preferences, security options
│   │   ├── holding/          # Portfolio asset allocation & position tables
│   │   ├── institution/      # Financial institution connection management
│   │   ├── main.dart         # Flutter entry point
│   │   ├── net-worth/        # Net worth breakdown, historical graphs
│   │   ├── notification/     # Notification drawer & badge indicators
│   │   ├── provider/         # Aggregator authentication flows (Plaid Link, SimpleFin, SnapTrade)
│   │   ├── routes/           # Navigation routes via `go_router`
│   │   ├── setup/            # Initial installation wizard
│   │   ├── shared/           # Common components, dialogs, formatters, widget state
│   │   ├── theme/            # FlexColorScheme design system & color palettes
│   │   ├── transaction/      # Transaction lists, filters, detail dialogs, categorization
│   │   └── user/             # User profile and security settings
│   └── pubspec.yaml          # Flutter dependencies & asset configurations
```

---

## 3. Backend Architecture (`backend/`)

The backend is built with [NestJS](https://nestjs.com/) in TypeScript, utilizing modular design, dependency injection, and TypeORM for database persistence.

### Key Architectural Layers

1. **Controllers (`*.controller.ts`)**:
    - Expose REST API endpoints and map path/query parameters to handlers.
    - Use NestJS Swagger annotations (`@ApiOperation`, `@ApiResponse`, `@ApiTags`) to auto-generate the OpenAPI spec.
    - Enforce authentication via `@UseGuards(AuthGuard)` and role limits via `AdminGuard`.

2. **Services (`*.service.ts`)**:
    - Contain business logic, calculations, database queries, and external service communication.
    - Inject TypeORM Repositories or Models.

3. **Database Entities & Models (`backend/src/database/model/` or `model/`)**:
    - Model entities inherit from TypeORM `BaseEntity` or custom abstractions.
    - Primary database engine: SQLite (managed via TypeORM).
    - All user data queries are strictly scoped by user ID (`user: { id: user.id }` or `userId: user.id`).

4. **API DTOs (`model/api/*.dto.ts`)**:
    - Define payload contracts for request bodies and API responses.
    - Enforce strict validation using `class-validator` (`@IsString()`, `@IsOptional()`, `@ValidateNested()`) and `class-transformer`.

5. **Financial Provider Connector Framework (`backend/src/providers/`)**:
    - Connector interface (`providers/base/core.ts`) standardizes balance fetching, transaction pulling, asset mapping, and error handling across provider drivers:
        - **Plaid**: Bank accounts, credit cards, investment holdings.
        - **SimpleFin**: Open-banking financial data aggregation.
        - **SnapTrade**: Brokerage and retail trading account synchronization.
        - **Zillow**: Real estate property valuation updates.
        - **Coinbase**: Cryptocurrency exchange balance and wallet tracking.
    - `SyncService` coordinates background synchronization jobs across all enabled providers.

6. **Asynchronous Background Processing (`backend/src/core/jobs/`)**:
    - Task execution and job queues are powered by [BullMQ](https://docs.bullmq.io/) over Redis.
    - Background tasks inherit from standard base abstractions:
        - `JobBase`: Manages queue setup, job lifecycle logging, and retry logic.
        - `JobDistributedBase`: Extends `JobBase` with Redis key-based distributed locking to guarantee single-instance execution across multi-replica deployments.

7. **Real-Time Streaming (`backend/src/sse/`)**:
    - `SseService` manages Server-Sent Event connections per user session.
    - Pushes live updates (e.g. sync progress, transaction updates, balance changes) directly to connected frontend clients without needing periodic polling.

8. **Authentication Architecture (`backend/src/auth/`)**:
    - Dual authentication mechanisms via Passport strategies:
        - **Local Auth**: Username/password with bcrypt password hashing and JWT access tokens stored in HTTP-only `auth_token` cookies or Bearer headers.
        - **OIDC / SSO**: OpenID Connect authorization code flow with discovery endpoint resolution, token exchange, and optional token introspection.

---

## 4. Frontend Architecture (`frontend/`)

The frontend is a cross-platform client written in Flutter (Dart), targeting Web browsers, Android devices, and iOS devices.

### Architecture & Tech Stack

- **Framework**: Flutter 3.x with Dart.
- **State Management**: [Riverpod](https://riverpod.dev/) (Riverpod 3.x) with code generation via `riverpod_generator` and `@riverpod` annotations.
- **Routing & Navigation**: `go_router` for client-side routing, tab navigation, query parameters, and deep links.
- **API Client**: Auto-generated OpenAPI Dart client (`frontend/lib/api/`) built directly from `backend/src/` OpenAPI specs.
- **Visualizations**: `fl_chart` for responsive net worth history graphs, cash flow breakdowns, and asset allocation pie/bar charts.
- **Theming**: `flex_color_scheme` powering light and dark design variants (`bliss_light`, `colored_dark`, `absolute_dark`).
- **Android Home Screen Widget**: Native Android AppWidget (`frontend/android/app/src/main/java/net/croudebush/sprout/widget/`) fed by Flutter background worker data via `home_widget`.

---

## 5. End-to-End Data Flow

### Account Synchronization Lifecycle

```
[ Scheduled Trigger or User Sync Request ]
                 |
                 v
      [ BullMQ Job Enqueued ]
                 |
                 v
   [ Provider Connector Execution ]
   (Plaid / SimpleFin / SnapTrade)
                 |
                 v
      [ Raw Data Normalization ]
                 |
                 v
    [ TypeORM Transaction Commit ]
(Accounts, Holdings, Transactions)
                 |
                 v
    [ Net Worth Daily Snapshot ]
                 |
                 v
     [ SSE Event Broadcasted ]
                 |
                 v
   [ Flutter Riverpod Invalidated ]
                 |
                 v
    [ UI Auto-Refreshes Graph ]
```

---

## 6. Developer & AI Agent Workflows

### Command Cheat Sheet

| Task                     | Command                                    |
| ------------------------ | ------------------------------------------ |
| Install Dependencies     | `npm run install:all`                      |
| Run Backend Unit Tests   | `npm run test --prefix backend`            |
| Backend Coverage Report  | `npm run test:cov --prefix backend`        |
| Build Backend Binary     | `npm run build --prefix backend`           |
| Export OpenAPI Spec      | `npm run export:api:spec --prefix backend` |
| Generate Dart API Client | `npm run api:generate:dart`                |
| Code Formatting          | `npm run prettier:write`                   |
| Build MkDocs Site        | `python3 -m mkdocs build`                  |
| Analyze Flutter Code     | `cd frontend && flutter analyze`           |
