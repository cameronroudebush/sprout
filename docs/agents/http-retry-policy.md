---
title: HTTP Retry Policy
description: How frontend HTTP retries are routed, configured, and diagnosed.
---

# HTTP Retry Policy

## Overview

The frontend root HTTP client in `frontend/lib/shared/api/base_api.dart` wraps its transport with `RetryClient`. It retries server errors (HTTP 500–599) up to two times. `RetryPolicyClient` routes requests that match a no-retry rule directly to the underlying transport, avoiding duplicate side effects while preserving retries for other API calls.

Rules use an HTTP method and a URL path suffix. Matching uses path segments, so base URL prefixes and trailing slashes do not affect the match. Current rule disables retries for `POST` paths ending in `/chat/new`.

## Adding a No-Retry Rule

Add a `NoRetryRequestRule` to `_noRetryRequestRules` in `base_api.dart`:

```dart
NoRetryRequestRule(method: 'POST', pathSuffix: ['chat', 'new']),
```

Use uppercase HTTP methods. Set `pathSuffix` to the final path segments, excluding any server base path. Add rules for operations that must not be replayed, such as requests that trigger billable jobs or create duplicate records. Leave idempotent reads on the retrying client unless there is a specific reason not to.

`RetryClient`'s response predicate only receives a response, not its originating request. `RetryPolicyClient` therefore makes the request-aware decision before delegating: matching requests go to the raw transport; all others go through `RetryClient`.

## Troubleshooting

Use browser network tools or platform HTTP logs to inspect request count and status. To trace routing temporarily, add an `onRetry` callback to `RetryClient` and a log in `RetryPolicyClient.send`; remove diagnostic prints after investigation. `rootHttpClientProvider` is kept alive, so fully restart the app after changing retry rules to recreate its client.

## Validation

Run `cd frontend && dart format lib/shared/api/base_api.dart lib/shared/api/retry_policy_client.dart && flutter analyze lib/shared/api/base_api.dart lib/shared/api/retry_policy_client.dart lib/chat/chat_provider.dart`.
