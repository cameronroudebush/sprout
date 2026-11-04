---
title: AI integration
description: Learn how AI can be used with Sprout.
---

# AI Integration

Sprout allows you to interact with your financial data using Large Language Models (LLMs). Once configured, the AI can analyze account balances, transaction activity, investment holdings, subscriptions, and—when budgeting is enabled—current-month budget performance.

!!! warning "Financial Disclaimer"

    Do not rely on AI for critical financial decisions. LLMs can "hallucinate" (provide incorrect data) or miss nuances in complex tax laws. Always consult a certified financial advisor before making significant changes to your portfolio.

## Data Privacy & Security

Review what context Sprout sends to your configured LLM provider before enabling this feature. Financial values and chat content leave your Sprout server and are subject to that provider's privacy and retention policies.

- **Financial context:** Chat requests include account types and subtypes, balances and balance history, interest rates, investment symbols and holding values/history, transaction dates and amounts, categories, and subscription amounts/frequency/last-paid dates. Transaction history and account/holding history follow the selected timeframe: one day (up to two days to avoid missing activity), three months, six months, or one year. Subscription summaries are derived from transaction history.
- **Budget context:** When budgeting is enabled, regular chat includes current calendar-month budget totals and per-category limits, spending, remaining amounts, and whether configured limits were exceeded. The separate budget overview uses the month selected by the user. Budget context is omitted from regular chat when budgeting is disabled.
- **Chat history:** Recent saved messages are included, up to the configured chat-history limit.
- **De-identification:** Sprout replaces account, transaction, and subscription identifiers plus category labels with generic tokens in financial context. Category labels are also pseudonymized in saved chat history before inclusion. Sprout maps tokens back in generated responses. Raw account and category database IDs, account names, usernames, and email addresses are not included in financial context.
- **Your input:** De-identification cannot remove personal information that you type directly into a message. Do not include passwords, access tokens, full account numbers, or other secrets in chat.

## Supported Models

- **Google Gemini:** Our primary integration for high-speed financial analysis.
- **OpenCode Zen:** Access to a curated set of models through the [OpenCode Zen](https://opencode.ai/docs/zen/) gateway.
- **OpenCode Go:** A low-cost subscription giving access to popular open coding models through the [OpenCode Go](https://opencode.ai/docs/go/) gateway.

Select the provider to use with the `sprout_server_prompt_type` environment variable (`gemini`, `opencode-zen`, or `opencode-go`).

## Setup Guide: Gemini

To use Gemini, you must generate an API key from Google AI Studio.

### 1. Generate your API Key

1. Sign in to [Google AI Studio](https://aistudio.google.com/app/apikey).
2. If this is your first time, accept the **Generative AI Terms of Service**.
3. Click **Create API Key**.
4. Choose **Create API key in a new project**.
5. Copy the generated key (it starts with `AIza...`).

### 2. Connect to Sprout

1. Configure [Sprout's runtime environment variable](../developer/configuration.md#ai) to include the key you've generated and restart sprout.

## Setup Guide: OpenCode Zen / Go

OpenCode Zen and OpenCode Go expose an OpenAI compatible API. Sprout reuses the same provider implementation for both, so setup only differs by the key and gateway.

### 1. Generate your API Key

1. Sign in to [OpenCode Zen](https://opencode.ai/auth).
2. Add billing details (for Zen) or subscribe to Go.
3. Copy your API key.

### 2. Connect to Sprout

1. Set `sprout_server_prompt_type` to `opencode-zen` or `opencode-go`. This selects the gateway URL (Zen or Go) automatically.
2. Set the shared API key with `sprout_server_prompt_openCode_key`.
3. Optionally override the models with `sprout_server_prompt_openCode_chatModel` and `sprout_server_prompt_openCode_overviewModel`.
4. Restart sprout.

!!! note "OpenAI Compatible Models Only"

    Sprout communicates with the OpenCode gateways through their `/chat/completions` endpoint. Only models served through that OpenAI compatible endpoint (for example GLM, Kimi, DeepSeek, and MiniMax) are supported.
