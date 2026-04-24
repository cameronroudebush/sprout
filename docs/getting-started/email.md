---
title: Email Configuration
description: Learn how to configure and use the automated email features in Sprout.
---

# Email Configuration

Sprout includes automated email capabilities to keep you updated on your financial health, including weekly summaries of your income, expenses, and net worth.

Email functionality is not required and is only intended to provide you automated reports. It is not used for anything else but support may be added in the future.

## Configuration Settings

To enable email functionality, you must set the following environment variables in your Sprout configuration.

| Variable                      | Description                                                 |
| :---------------------------- | :---------------------------------------------------------- |
| `sprout_server_email_enabled` | Set to `true` to enable the mailing service.                |
| `sprout_server_email_from`    | The email address or name that appears in the "From" field. |
| `sprout_server_email_host`    | The SMTP server host (e.g., `smtp.gmail.com`).              |
| `sprout_server_email_user`    | The username for your SMTP server.                          |
| `sprout_server_email_pass`    | The password or App Password for your SMTP server.          |

Fore more configuration information, [see the configuration page](./configuration.md).

## Using email

To utilize email, it is by default disabled for every user. To enable it, navigate to settings, confirm your email is populated, then set the update interval. If the interval is not set, or no email is set, then you will not receive the email as part of the reoccurring job.

## Email Varieties

### Weekly Update

Sprout automatically aggregates your data from the last **7** days to generate a personalized report including the following information

- Transactions
- Weekly Income
- Weekly expenses
- Overall Net Worth
