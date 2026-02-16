---
title: Development - Providers
description: Learn about development with the providers of Sprout.
---

## SimpleFIN

<p align="center">
    <img src="https://www.simplefin.org/img/logo.svg" width="15%">
</p>

SimpleFIN was Sprout's original bread and butter, serving as the foundational integration that launched the platform. While Sprout has since expanded to support a diverse array of providers, SimpleFIN remains a favorite due to its refreshing simplicity and "hacker-friendly" ethos.

It acts as a bridge, normalizing the chaotic landscape of financial institution APIs into a single, clean, and read-only JSON stream. Unlike heavy-handed enterprise aggregators that require complex OAuth handshakes and SDKs, SimpleFIN provides a streamlined path from "Connecting Account" to "Getting Data."

### Why Developers Love It

The "Simple" in SimpleFIN is not an exaggeration. The integration complexity is virtually zero. Once a user configures their accounts in the SimpleFIN Bridge, they are issued a setup token. This token is exchanged once for an **Access URL**.

From that point forward, acquiring data is as easy as issuing a single HTTP request. There are no refresh tokens to rotate, no complex signing secrets to manage, and no heavy client libraries required.

**Example: The One-Liner**

Once you have your Access URL, grabbing every account, balance, and transaction for a user is literally this simple:

```bash
# It really is just one command
curl -L "${ACCESS_URL}/accounts"

```

**The Response:**
You receive a beautifully normalized JSON object containing everything you need—balances, currency types, and transaction history—ready for ingestion.

```json
{
    "errors": ["You must reauthenticate."],
    "accounts": [
        {
            "org": {
                "domain": "mybank.com",
                "sfin-url": "https://sfin.mybank.com"
            },
            "id": "2930002",
            "name": "Savings",
            "currency": "USD",
            "balance": "100.23",
            "available-balance": "75.23",
            "balance-date": 978366153,
            "transactions": []
        }
    ]
}
```

### Try Before You Buy: Development Tokens

One of the strongest features for testing out SimpleFIN is the **zero-barrier entry**. You do not need to purchase a SimpleFIN subscription or connect your real bank accounts to try out this provider.

SimpleFIN provides **Demo Tokens** specifically for testing. These tokens generate realistic, static data that allows you to test Sprout's ingestion engine, UI rendering, and calculation logic without touching real money.

- **Documentation:** Grab a demo token instantly from the [SimpleFIN Developer Guide](https://beta-bridge.simplefin.org/info/developers).

### Takeaways & Improvements

While SimpleFIN is fantastic for its intended purpose, it occupies a specific niche. Here is an honest assessment of where it shines and where it faces challenges compared to enterprise-grade aggregators (like Plaid).

| **Strength**                                                                                   | **Area for Improvement**                                                                                                                                                                                                                                                    |
| ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Simplicity:** The REST API is incredibly straightforward and easy to debug.                  | **Data Freshness:** Syncs are not always real-time. Data is cached and refreshed periodically (usually daily), which prevents "instant" update experiences.                                                                                                                 |
| **Cost:** It is significantly cheaper than enterprise alternatives, making it very accessible. | **Metadata Richness:** Transaction data is sometimes sparse. Merchant logos, precise geolocations, and categorized merchant codes are often missing or less detailed.                                                                                                       |
| **Privacy:** It acts as a strict read-only proxy, reducing the risk surface for developers.    | **Connection Stability:** As a bridge often relying on other aggregators (like MX) under the hood, connection stability is dependent on the upstream provider, not just SimpleFIN itself. We've experienced many times where data just doesn't update for days due to this. |
