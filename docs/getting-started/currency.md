---
title: Currency Support
description: Learn what currencies Sprout supports
---

# Currency Support

Sprout implements a **"Source of Truth"** model for financial data. While accounts may exist in various local currencies (**USD**, **EUR**, **GBP**, etc.), the system dynamically normalizes all numeric values to the user's preferred display currency.

> **Key Philosophy:** The database preserves the original transaction value and original currency. Conversion is a **volatile transformation** that occurs just-in-time when data is used.

---

## User Configuration

To set what currency you would like to view your data as, you can navigate to the user settings and adjust the `currency` setting. We provide some supported defaults. If you would like to add additional currencies, please [open a ticket](https://github.com/cameronroudebush/sprout/issues).

## Backend: The Currency Engine

The backend core consists of the `ExchangeRateJob` and the `CurrencyHelper`. Together, they manage live exchange rates and provide the logic for data transformation.

### Exchange Rate Synchronization

Exchange rates are managed by the `ExchangeRateJob`. This job automatically populates live exchange rates via an API call. We update these rates every **6 hours**, or whenever the server is restarted.

### The Serialization Pipeline

While the backend models consist of whatever currency the provider gives us, we only ship the converted currency to the users target currency across the API. This means the backend always contains the original value with the original currency and the API will only ever receive the users configured target currency, and will never tell you a currency otherwise.

**If a currency cannot be determined, it assumes it's USD.**

---

## Frontend Integration

The frontend application is strictly a **consumer** of processed data. Because the backend handles converting every relevant financial value to a consistent currency, it does not have to perform currency math; it only handles formatting and de-identification.

### Dynamic Formatting

By leveraging the `intl` package, the frontend identifies the correct currency symbol and locale formatting based on the user's settings. The `NumberFormat.simpleCurrency` function ensures that as new currencies are added to the backend Enum, the frontend remains compatible without manual updates.

---

## Currency Support

Below are the currently supported currencies

| Currency               | ISO Code | Symbol |
| :--------------------- | :------- | :----- |
| United States Dollar   | **USD**  | $      |
| Euro                   | **EUR**  | €      |
| British Pound Sterling | **GBP**  | £      |
| Canadian Dollar        | **CAD**  | $      |
| Australian Dollar      | **AUD**  | $      |
| Japanese Yen           | **JPY**  | ¥      |
| Chinese Yuan           | **CNY**  | ¥      |
