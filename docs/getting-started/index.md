---
hide:
    - toc
title: Getting started
description: Learn how to start using Sprout today.
---

<style>
.md-footer__link--prev { display: none; }
#getting-started {display: none;}
</style>

# Getting Started

<p align="center">
    <img src="https://media.githubusercontent.com/media/cameronroudebush/sprout/master/frontend/assets/logo/color-transparent.png" width="50%">
</p>

**Welcome to Sprout!** Follow these steps to configure and launch your self-hosted instance.

## Prerequisites

- [Docker Engine](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/).
- A host or server with a persistent directory for Sprout's database and backups.
- (**Recommended for internet-facing instances**) A domain and HTTPS reverse proxy.

## Install Sprout with Docker Compose

1. **Create a directory for your deployment.** Run the following commands, then use this directory for the files below:

    ```bash
    mkdir sprout
    cd sprout
    ```

2. **Generate an encryption key.** Run this command and keep its output private:

    ```bash
    docker run --rm croudebush/sprout:stable generate-key
    ```

    Save the key somewhere secure. Sprout uses it to encrypt sensitive data; losing or changing it can make encrypted data unreadable. See [encryption key details](./configuration.md#generating-an-encryption-key).

3. **Create `compose.yaml`** in the deployment directory:

    ```yaml title="compose.yaml" linenums="1"
    services:
        sprout:
            container_name: sprout
            image: croudebush/sprout:stable
            restart: unless-stopped
            ports:
                - "80:80"
            volumes:
                - /appdata/sprout:/sprout
            environment:
                TZ: America/New_York
                sprout_encryptionKey: paste-your-generated-key-here
                sprout_server_publicUrl: http://localhost
    ```

    Update the example values:

    - Replace the encryption key placeholder with your generated key.
    - Change `/appdata/sprout` to a persistent host directory.
    - Set `TZ` to your [time zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).
    - Set the public URL to the address users will open. Use your HTTPS URL behind a reverse proxy.
    - Keep your Compose file private because it contains your encryption key.

4. **Start Sprout.** From the directory containing `compose.yaml`, run:

    ```bash
    docker compose up -d
    ```

5. **Open Sprout** at the address configured in Compose (by default, [http://localhost](http://localhost)) and complete the in-app setup. For remote access and connecting from other devices, see [Accessing Sprout](./access.md).

For all available settings, see [Configuration](./configuration.md).

## Configure your instance

After setup, continue with the guides most relevant to your deployment:

- **[Authentication](./auth.md)**: Configure local login or OIDC.
- **[Notifications](./notification.md)**: Set up push notifications.
- **[AI](./llm.md)** and **[Email](./email.md)**: Configure optional integrations.
- **[Access](./access.md)**: Connect from phones and other devices.
- **[Backups](./backups.md)**: Protect your database and encryption key.
- **[Currencies](./currency.md)**: Configure supported currencies.
