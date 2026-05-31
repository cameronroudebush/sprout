---
title: Mobile Apps
description: Download and configure the native Sprout mobile applications and home screen widgets.
---

# Sprout Mobile Apps

While the Web UI and PWA offer great flexibility, we also provide a native mobile experience for deeper OS integration, including push notifications and home screen widgets.

## Android

We offer a native Android application built with Flutter to provide a smooth, integrated mobile experience for Sprout users.

### Installation Methods

#### Official Google Play Store (Closed Testing)

The official app is hosted on the Google Play Store. Because the app is currently in an active testing phase, you must join our testing community to gain visibility of the store listing.

**Steps to Gain Access:**

1. **Join the Testing Group:** Navigate to the [Sprout Android Testing Google Group](https://groups.google.com/g/sprout-testers).
2. **Opt-In:** Click the **Join Group** button while logged into the primary Google Account associated with your Android device.
3. **Download the App:** Once your group membership is active, click this [Google Play Store Link](https://play.google.com/store/apps/details?id=net.croudebush.sprout) to view the listing, opt into the testing track, and download the app directly to your device.

_Note: If you run into any issues gaining access via the group link, please reach out to the maintainer via the contact information listed on the [developer's GitHub profile](https://github.com/cameronroudebush)._

#### Manual Installation (Sideload APK)

If you prefer to avoid app stores entirely or want to test independent builds, you can download the latest compiled production APKs directly from the [GitHub Releases page](https://github.com/cameronroudebush/sprout/releases).

### Home Screen Widgets

The Android app includes native home screen widgets designed to keep you updated on your financial status at a glance.

- **Overview Widget:** Displays a quick snapshot of your current net worth, including recent numerical and percentage changes.
- **Transactions Widget:** Shows a scrolling list of your most recent transactions, displaying the merchant, category, amount, and pending status.

!!! note "Widget Requirements"

    - **Background Updates:** Widgets automatically refresh roughly once every hour to keep your data fresh without impacting battery life.
    - **Configuration Required:** To see widget support on your home screen, you must explicitly enable the widget permissions under your **User Settings** inside the app.

---

## iOS

At this time, **we do not offer a native iOS application** on the Apple App Store. We hope to expand the Flutter codebase to iOS devices in a future development cycle.

### Recommended Setup for Apple Users

In the meantime, you can achieve a nearly identical native app experience by installing Sprout as a **Progressive Web App (PWA)**:

1. Open your Sprout Web UI instance inside **Safari** on your iPhone or iPad.
2. Tap the **Share** button in the browser toolbar.
3. Scroll down and select **Add to Home Screen**.

For more information, see the [PWA Setup Guide](./access.md#progressive-web-app-pwa).
