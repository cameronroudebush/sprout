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

## Zillow

<p align="center">
    <img src="https://www.zillow.com/apple-touch-icon.png" width="15%">
</p>

While SimpleFIN handles the **liquid** side of a user's net worth, Zillow integration brings in the **illiquid** real estate assets. In Sprout, Zillow serves as a zero-config valuation engine. If a user provides a valid US-based property address, Sprout can track its **Zestimate** automatically.

### How it Works

Sprout uses a localized scraping/lookup strategy. Instead of a standard REST endpoint with an Authorization header, Sprout identifies a property's unique **ZPID** (Zillow Property ID) based on the address provided and produces the following info:

```json linenums="1"
{
    "zpid": "3572154",
    "zestimate": "20942385",
    "rentZestimate": "1700"
}
```

### Development Testing

Because Zillow doesn't require a login, testing is straightforward. You can use any valid residential US address to test the ingestion flow.

!!! note

    During development, be mindful of rate-limiting. Since we aren't using an official API key, excessive rapid polling from a single IP can lead to temporary blocks. Sprout handles this by using some pretty aggressive rate limiting per day.

### Takeaways & Improvements

Zillow is a powerful tool for completing the "Full Net Worth" picture, but it has specific constraints.

| **Strength**                                                                                 | **Area for Improvement**                                                                                                                        |
| -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| **Zero Friction**: No signup, no keys, and no tokens for the user or the developer.          | **Geographic Limit**: Currently only supports properties within the United States.                                                              |
| **Persistence**: Once an address is linked, it almost never "breaks" or requires re-linking. | **Estimation Accuracy**: The **Zestimate** is an algorithm, not a formal appraisal. It can fluctuate significantly based on local market noise. |
|                                                                                              | **Gray Area**: We don't utilize Zillow's API directly as it's intended for commercial use. Instead we rely on data scraping                     |

## Plaid

<p align="center">
    <img src="https://plaid.com/assets/img/favicons/apple-touch-icon.png" width="15%">
</p>

If **SimpleFIN** is the "developer-friendly" bridge, **Plaid** is the enterprise-grade powerhouse. It is the industry standard for financial connectivity, powering massive apps like Venmo and Robinhood. In Sprout, Plaid provides a level of data depth and sync frequency that other providers simply cannot match, though it comes at the cost of significantly higher complexity and overhead.

### The Developer's Burden: Complexity & Maintenance

Integrating Plaid is a major undertaking compared to SimpleFIN. It is not a "one-and-done" REST call; it is a full-lifecycle management system.

**1. The Link Flow (OAuth)**
Unlike SimpleFIN’s setup tokens, Plaid requires a coordinated dance between your frontend and backend. You must generate a short-lived `link_token` on the server, pass it to the frontend to initialize the **Plaid Link SDK**, and then catch a `public_token` on success to exchange it back on the server for a permanent `access_token`.

**2. Token Management & Rotation**
`access_tokens` are critical PII. In Sprout, we must:

- Encrypt them at rest, **which we do**.
- Handle **Update Mode** when a user changes their bank password, which requires re-launching the Link SDK to repair the existing Item.

**3. Product Readiness**
Plaid data is partitioned into **Products** (Transactions, Investments, Liabilities). When a user first links an account, you cannot simply grab data immediately. You often have to wait for an initial background pull to complete, which can lead to `PRODUCT_NOT_READY` errors if your sync logic is too aggressive.

### The Payoff: Real-Time Data & Rich Metadata

Despite the maintenance **tax**, Plaid is the only provider that offers a truly **live** experience.

**Sync Frequency**
While SimpleFIN is typically limited to daily refreshes due to upstream caching, **Plaid can be synced up to 4 times per day** in our background workers. This ensures that a morning coffee purchase shows up in Sprout by lunchtime.

### Takeaways & Improvements

Plaid is a **high-maintenance**, **high-reward** provider. It is the best choice for users who want a "set it and forget it" experience with maximum detail.

| **Strength**                                                                                                                                | **Area for Improvement**                                                                                                                               |
| :------------------------------------------------------------------------------------------------------------------------------------------ | :----------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Data Freshness:** Supports up to 4 syncs per day, providing near real-time updates.                                                       | **High Cost:** Plaid is significantly more expensive. While they have a free "Development" tier, Production usage carries per-item and per-call costs. |
| **Rich Metadata:** Includes merchant logos, high-fidelity categories, and investment holdings (shares, cost basis, etc.).                   | **Integration Heavy:** Requires SDKs for both frontend (Flutter) and backend (Node/TS), plus complex token exchange logic.                             |
| **Reliability:** Direct OAuth integrations with major banks (Chase, Wells Fargo) mean fewer "broken" connections compared to proxy bridges. |                                                                                                                                                        |

### Development Testing

Plaid provides a robust **Sandbox** environment that simulates almost every banking scenario. You can use auto populated link phone numbers/logins to get examples of accounts easily, just with sandbox tokens.

A key part of developing for Plaid in Sprout is handling the transition from Sandbox to **Development** (real data, limited accounts) and finally **Production**. Each environment requires its own secret key, which should be managed strictly via environment variables.
