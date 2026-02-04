---
title: AI integration
description: Learn how to AI can be used with Sprout.
---

# AI Integration

Sprout allows you to interact with your financial data using Large Language Models (LLMs). Once configured, the AI can analyze your account balances, transaction history, and investment holdings to provide insights and trends.

!!! warning "Financial Disclaimer"

    Do not rely on AI for critical financial decisions. LLMs can "hallucinate" (provide incorrect data) or miss nuances in complex tax laws. Always consult a certified financial advisor before making significant changes to your portfolio.

## Data Privacy & Security

We take your financial privacy seriously:

- **Encryption:** API keys are encrypted at rest.
- **Minimal Exposure:** Sprout only sends the last 90 days of transaction history to minimize data exposure.

## Supported Models

- **Google Gemini:** Currently our primary integration for high-speed financial analysis.

## Setup Guide: Gemini

To use Gemini, you must generate an API key from Google AI Studio.

### 1. Generate your API Key

1. Sign in to [Google AI Studio](https://aistudio.google.com/app/apikey).
2. If this is your first time, accept the **Generative AI Terms of Service**.
3. Click **Create API Key**.
4. Choose **Create API key in a new project**.
5. Copy the generated key (it starts with `AIza...`).

### 2. Connect to Sprout

1. Open Sprout and navigate to your **Settings** (Click your username in the sidebar).
2. Paste your key into the **Gemini API Key** field and click **Save**.

_Note: Once saved, your key is hidden for security. You can overwrite it at any time if you generate a new one._
