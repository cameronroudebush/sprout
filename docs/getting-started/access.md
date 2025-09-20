---
title: Accessing
description: Learn how to access Sprout.
---

# Accessing Sprout

Sprout is designed to be accessible wherever you are. You can use it on your mobile device through our [App's](#apps) or as a [Progressive Web App (PWA)](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps).

## Web Interface Access

This is the primary way to interact with Sprout. Once the Docker container is running, you can connect to the web UI using one of two methods:

-   **Local Access**: If you are on the same machine that is running Docker, you can access Sprout by navigating your web browser to [`http://localhost`](http://localhost).
    -   If you mapped the container to a different port (e.g., you used `-p 8080:80`), you would use that port instead (e.g., `http://localhost:8080`).
-   **Reverse Proxy Access**: If you've set up a reverse proxy to make Sprout available outside your home network or to use a custom domain with SSL, simply navigate to the URL you configured (e.g., `https://sprout.yourdomain.com`).
    -   This is the **recommended** way to access Sprout for daily use, especially for setting up the PWA.

## Progressive Web App (PWA)

For an app-like experience on any device without installing anything from an app store, you can use the PWA.

**To install the PWA:**

1. Navigate to your Sprout instance in a modern mobile or desktop web browser (like Chrome, Safari, or Firefox).
2. Open the browser's menu.
3. Tap the **"Add to Home Screen"** or **"Install App"** option.

An icon for Sprout will be added to your device's home screen, allowing you to launch it just like a native app.

## App's

### Android

We offer a native Android application for the best possible mobile experience.

#### Google Play Store

The official app is available on the Google Play Store. It provides access to all of Sprout's features with a native interface.

**You must request access to this application as we are still in alpha.** Please [see here](#beta-testing) for how to do that.

You can find the [app here](https://play.google.com/store/apps/details?id=net.croudebush.sprout&pcampaignid=web_share).

### IOS

As of right now, we do not offer an IOS app. This will hopefully change in the future. In the meantime, we suggest [using PWA](#progressive-web-app-pwa).

### Beta Testing

For users who want to test upcoming features before they are released, we offer a closed testing program.

To request access, please email the developer. You can find contact information on the [developer's GitHub profile](https://github.com/cameronroudebush).

### Manual Downloads

If you'd rather not download the apps from an app store, you can also find them located on [the releases](https://github.com/cameronroudebush/sprout/releases) as they occur.
