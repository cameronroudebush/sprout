---
title: Accessing
description: Learn how to access your Sprout instance via the web and PWA.
---

# Accessing Sprout

Sprout is designed to be accessible wherever you are. Once your Docker container is running, you can interact with the web interface directly, install it as a Progressive Web App (PWA) for a mobile-friendly experience, or use a native app.

!!! note

    Looking for information on native mobile apps and widgets? Check out the [Mobile Apps documentation](./apps.md).

## Web Interface

Connecting to the web UI is the primary way to interact with Sprout. You can access it using one of two methods:

- **Local Access:** If you are on the same machine running the Docker container, open your browser and navigate to [`http://localhost`](http://localhost).
    - _Note:_ If you mapped the container to a different port (e.g., `-p 8080:80`), include that port in the URL (e.g., `http://localhost:8080`).
- **Reverse Proxy Access (Recommended):** If you've set up a reverse proxy to expose Sprout outside your home network or to secure it with an SSL certificate, navigate to your configured custom domain (e.g., `https://sprout.yourdomain.com`). This is the best approach for daily use and is required for a seamless PWA setup.

## Progressive Web App (PWA)

For an app-like experience without relying on traditional app stores, you can install Sprout as a PWA.

**How to install the PWA:**

1.  Navigate to your Sprout instance URL in a modern web browser (like Chrome, Safari, or Firefox) on your mobile device or desktop.
2.  Open the browser's settings menu.
3.  Select **Add to Home Screen** or **Install App**.

An icon for Sprout will appear on your device's home screen, allowing you to launch it in a standalone window just like a native app.
