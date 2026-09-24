---
title: AI integration
description: Learn how AI can be used with Sprout.
---

# AI Integration

Sprout allows you to interact with your financial data using Large Language Models (LLMs). Once configured, the AI can analyze your account balances, transaction history, and investment holdings to provide insights and trends.

!!! warning "Financial Disclaimer"

    Do not rely on AI for critical financial decisions. LLMs can "hallucinate" (provide incorrect data) or miss nuances in complex tax laws. Always consult a certified financial advisor before making significant changes to your portfolio.

## Data Privacy & Security

We take your financial privacy seriously:

- **Minimal Exposure:** Sprout only sends the last 90 days of transaction history to minimize data exposure.
- **Masked Data:** Sprout replaces numerous identifiers with generic IDs when passed to the LLM to prevent data leakage. This is then mapped back to the real text when we receive the response. This data includes: account IDs, transaction descriptions.

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
