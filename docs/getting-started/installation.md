---
title: Installation
description: Learn how to install and use Sprout.
---

# Installation

The recommended way to install Sprout is with a Docker image.

## Docker Setup

To get started, choose either the Docker Compose or Docker Run method below.

=== "Docker Compose"

    ```yaml title="compose.yml" linenums="1"
    services:
      sprout:
        container_name: sprout
        image: croudebush/sprout:stable
        volumes:
          - /appdata/sprout:/sprout #(1)!
        ports:
          - 80:80
        restart: unless-stopped
        environment:
          TZ: America/New_York
          sprout_encryptionKey: ${SPROUT_ENCRYPTION_KEY} #(2)!
    ```

    1.  Sprout's configuration and database is under `/sprout`.
    2.  See [configuration](./configuration.md) for more info

=== "Docker Run"

    ```sh linenums="1"
    docker run -d \
      --name=sprout \
      -v /appdata/sprout:/sprout \ # (1)!
      -p 80:80 \
      -e TZ=America/New_York \
      -e sprout_encryptionKey=${SPROUT_ENCRYPTION_KEY} \ # (2)!
      --restart unless-stopped \
      croudebush/sprout:stable
    ```

    1.  Sprout's configuration and database is under `/sprout`.
    2.  See [configuration](./configuration.md) for more info

!!! warning

    You must configure an encryption key or Sprout will fail to start. You should check out [configuration](./configuration.md) for more info on how to configure Sprout.

## Docker Images

Sprout offers [Docker images](https://hub.docker.com/r/croudebush/sprout) to suit different needs.

- `croudebush/sprout:stable`: **(Recommended)** This is the image for most users. It is only updated with tagged, stable releases from the `main` branch.
- `croudebush/sprout:dev`: This image is tied directly to the `main` branch and updates with every commit. Use this for testing the latest features, but expect potential instability.
