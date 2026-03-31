---
hide:
title: Providers
description: Learn about the providers of Sprout.
---

# Data Providers

To save you from the tedious task of manual data entry, Sprout connects directly to your financial institutions using secure **Data Providers**. These services act as a bridge, safely fetching your account balances and transaction history so Sprout can display them in your dashboard.

Below is a list of the currently supported providers.

---

## SimpleFIN

<p align="center">
    <img src="https://www.simplefin.org/img/logo.svg" width="15%">
</p>

**SimpleFIN** is a popular choice for users who want a straightforward, affordable, and privacy-focused way to connect their bank accounts. It focuses on doing one thing well: securely reading your financial data.

### How to Connect

Connecting Sprout to SimpleFIN is easy and only needs to be done once.

#### **Get a SimpleFIN Token:**

- Log in to your account on the [SimpleFIN Bridge Website](https://beta-bridge.simplefin.org/).
- Navigate to the "Connect an App" section (or click [here to create a token](https://beta-bridge.simplefin.org/my-account/tokens/create)).
- Follow the prompts to select which bank accounts you want to share with Sprout.
- At the end of the process, you will be given a long **Setup Token string**. Copy this to your clipboard.

#### **Paste into Sprout:**

- Open your **User Settings** in Sprout.
- Find the **Finance Provider Settings** section.
- Select **SimpleFIN API Token** and paste your Setup Token into the API Key field.

#### **Done!**

- Now when you go to link an account, Sprout will provide you SimpleFIN as an option.

### Why Choose SimpleFIN?

- **Privacy-First:** SimpleFIN acts as a strict read-only proxy. It does not store your bank credentials permanently and passes data directly to you.
- **Broad Support:** Through its backend partners (like MX), it supports thousands of US and Canadian financial institutions.
- **Affordable:** It offers a very low-cost subscription model compared to enterprise aggregators.

For more details on their service and pricing, visit the official [SimpleFIN Website](https://www.simplefin.org/).

## Zillow

<p align="center">
    <img src="https://www.zillow.com/apple-touch-icon.png" width="15%">
</p>

Sprout uses Zillow to provide automatic valuation updates for your real estate assets. By linking a property via its physical address, Sprout can fetch the current **Zestimate** to ensure your net worth reflects the most up-to-date market data for your home or investment properties.

!!! warning

    **Zestimates** are not always the most accurate representations of your property value. Only use these as a suggestion for trend tracking.

### How it Works

Unlike many financial integrations, Zillow support in Sprout is designed to be "plug-and-play."

- **No API Keys Required**: You do not need to sign up for a developer account or manage complex API keys. Sprout handles the data retrieval internally.
- **Address-Based Tracking**: Simply provide the street address, city, state, and zip code of your property.
    - We'll locate the Zillow Property ID and keep this for later updates
- **Automatic Updates**: Once a property is linked, Sprout will periodically refresh the valuation, tracking changes in your home equity over time without any manual input.
