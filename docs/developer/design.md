---
title: UI & Design Guidelines
description: UI design system, typography, color palettes, theme system, and component guidelines for Sprout.
---

# Sprout UI & Design Guidelines

This document outlines the visual design system, typography, color schemes, component patterns, and UI conventions used across Sprout's Flutter application.

---

## 1. Design System Overview

Sprout's UI design focuses on clarity, readability of complex financial data, responsiveness across web and mobile screen sizes, and consistent dark/light themes.

- **Design Standard**: Material 3 (M3) guidelines enforced via `FlexColorScheme`.
- **Primary Typography**: Custom crisp font configuration (`RobotoCrisp`).
- **Layout Adaptability**: Mobile-first responsive views scaling cleanly up to desktop monitor resolutions.

---

## 2. Typography

Sprout uses `RobotoCrisp` as its primary font family across all themes, defined in theme configurations via `FlexThemeData`.

### Typography Hierarchy

| Style Role              | Font Family                   | Typical Usage                                                  |
| ----------------------- | ----------------------------- | -------------------------------------------------------------- |
| **Display / Title**     | `RobotoCrisp` (Bold)          | Net worth total header, hero financial callouts                |
| **Headline / Subhead**  | `RobotoCrisp` (Semi-Bold)     | Section headers, card titles, category group titles            |
| **Body / Content**      | `RobotoCrisp` (Regular)       | Transaction list items, account descriptions, drawer items     |
| **Caption / Subtitle**  | `RobotoCrisp` (Light/Regular) | Timestamps, institution connection statuses, transaction dates |
| **Monospace / Numbers** | `RobotoCrisp` / Numeric       | Currency amounts, stock tickers, percentage gains/losses       |

---

## 3. Color Palette & Theme System

Sprout supports three theme variants configured in `frontend/lib/theme/`:

1. **`colored_dark.dart`**: The default dark theme featuring Sprout's signature slate/blue surfaces (`#111418` scaffold background, `#191c20` cards).
2. **`absolute_dark.dart`**: An OLED-friendly true black theme (`#000000` scaffold, `#080808` cards/dialogs).
3. **`bliss_light.dart`**: A clean, light-mode theme with crisp off-white surfaces (`#f5f8fc`).

### Core Color Palette

| Token Name              | Hex Code                             | Purpose / Usage                                                    |
| ----------------------- | ------------------------------------ | ------------------------------------------------------------------ |
| **`primaryBlue`**       | `#6B9AC4`                            | Primary brand accent color, active selections, progress indicators |
| **Secondary Accent**    | `#116383`                            | Secondary buttons, borders, divider tints, chips                   |
| **Primary Container**   | `#001E2C` (Dark) / `#D1E4FF` (Light) | Highlighted selection states, badge backgrounds                    |
| **Secondary Container** | `#C2E8FF`                            | Secondary button containers and pill badges                        |
| **Tertiary Accent**     | `#D6BEE4` / `#6B5778`                | Special indicators, AI agent callouts, category badges             |
| **Error / Alert**       | `#BA1A1A`                            | Negative net worth changes, delete actions, failed syncs           |

```
                       PRIMARY BLUE            SECONDARY ACCENT
                        [ #6B9AC4 ]              [ #116383 ]

                       DARK SURFACE            LIGHT SURFACE
                        [ #191C20 ]              [ #F5F8FC ]
```

---

## 4. UI Components & Patterns

### Cards & Dialogs

- **Border Radius**: Consistent `12.0px` corner radius across cards and dialogs (`cardRadius: 12.0`, `dialogRadius: 12.0`).
- **Surface Elevation**: Low surface tint and subtle borders rather than heavy drop shadows.
- **Backgrounds**: Cards use elevated background colors (`#191c20` in colored dark, `#080808` in absolute dark, `#f5f8fc` in light).

### Buttons & Inputs

- **Primary Buttons**: Filled buttons using `ThemeHelpers.primaryBlue` (`backgroundColor: primary`, `foregroundColor: onPrimary`).
- **Secondary Buttons**: Styled with `secondary` scheme color (`#116383`).
- **Error Buttons**: Styled with `error` scheme color (`#ba1a1a`).
- **Form Inputs**: Outlined input decoration (`inputDecoratorBorderType: FlexInputBorderType.outline`) with filled surface fills.

### Navigation & Layout

- **Mobile Navigation**: Bottom navigation bar (`BottomNavigationBar`) for key sections (Dashboard/Net Worth, Accounts, Transactions, Cash Flow).
- **Desktop Navigation**: Navigation rail / sidebar (`NavigationRail`) with top-level section routing.

---

## 5. Data Visualization & Charts (`fl_chart`)

Financial charts in Sprout (Net Worth timeline, Cash Flow trend, Asset Allocation) adhere to strict visual guidelines:

- **Net Worth Line Charts**:
    - Gradient fills beneath lines using primary blue with opacity transitions.
    - Interactive tooltips displaying exact timestamped currency values upon tap/hover.
- **Cash Flow Bar Charts**:
    - Color-coded bars: Positive/Income (Green accent), Negative/Expenses (Red/Amber accent).
- **Asset Breakdown Donut Charts**:
    - Category-based color mapping with legend key pills below the graph.

---

## 6. Iconography & Badges

- **Icons**: Material Design Icons (`Icons.*`) paired with custom brand SVG assets (`assets/favicon-bg.svg`, `assets/logo.png`).
- **Chips & Badges**:
    - Rounded rectangle borders (`borderRadius: 8.0px`).
    - Outline width of `1px` with subtle opacity (`#116383` at 15–30% opacity).
    - Used for category tags, transaction status labels, and account type indicators.
