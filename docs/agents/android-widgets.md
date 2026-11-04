---
title: Android Home Screen Widgets
description: Integration and maintenance notes for Sprout's Android home screen widgets.
---

# Android Home Screen Widgets

## Integration Overview

Sprout widgets use Flutter's `home_widget` package to persist a shared JSON payload. The Android `AppWidgetProvider` classes read this payload through `WidgetUtils`; widget data is prepared in `frontend/lib/shared/providers/widget_provider.dart`.

## Adding a Widget

1. Add an `AppWidgetProvider` under `frontend/android/app/src/main/java/net/croudebush/sprout/widget/`.
2. Add its layout and preview under `frontend/android/app/src/main/res/layout/`, plus an app-widget descriptor under `res/xml/`.
3. Register provider and descriptor in `AndroidManifest.xml`; add its label and description in `res/values/strings.xml`.
4. Add its `androidName` to `WidgetSync._saveToNative()` so data updates and sign-out clears reach it.
5. Add the fields it consumes to `_prepareData()`. Use `portfolioSummaryProvider` or another authenticated provider rather than making network requests from native Android code.
6. Keep presentation theme-aware and provide an empty/failure state. Open widgets into `MainActivity`.
7. Update the public widget list and requirements in `docs/getting-started/apps.md`; refresh its screenshot when a visible widget design changes.

## Portfolio Widget Data Contract

`widget_data` has a `data` object with these portfolio fields:

| Field                    | Meaning                                                     |
| ------------------------ | ----------------------------------------------------------- |
| `portfolioChange`        | Signed estimated dollar change since previous market close. |
| `portfolioChangePercent` | Daily portfolio percentage change, including sign.          |
| `majorIndices`           | Up to three index records from the major holdings endpoint. |
| `updateTime`             | Timestamp displayed on each widget.                         |

Each `majorIndices` record contains `name`, signed `change` in points, signed `changePercent`, and a per-index `statusColor`. Invalid index quotes display as unavailable. Index data comes from `majorIndicesProvider` and the `GET /holding/live/major` endpoint; S&P 500 fields do not belong in the portfolio summary DTO. The backend `GET /holding/portfolio/summary` endpoint scopes holdings to the authenticated user, values valid live quotes, and falls back to stored holding values when quotes are unavailable.

The portfolio widget keeps portfolio percentage and dollar changes prominent, with the S&P 500, DJIA, and NASDAQ percentage and point changes alongside them. It does not display total portfolio value or net worth.

## User-Facing Status Messages

Keep native widget failure text consistent with `WidgetSync._prepareData()`:

- `Session Expired` when there is no active user configuration.
- `Widget Setting Disabled` when widgets are disabled in user settings.
- `No data available` when widget data cannot be prepared.

## Refresh Behavior

The portfolio summary provider refreshes every 15 minutes, major indices every 5 minutes, and forced-update SSE events trigger a refresh. Android's periodic widget update and `Workmanager` are 30-minute fallbacks. Do not perform quote/API requests inside the native widget provider.

## Validation

- Run the relevant backend holding unit tests.
- Run `cd frontend && dart format . && flutter analyze`.
- Build Android with `cd frontend && flutter build apk` when Android SDK tooling is available.
