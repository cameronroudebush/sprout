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
          sprout_providers_simpleFIN_accessToken: ${SIMPLE_FIN_ACCESS_URL}
          sprout_server_jwtExpirationTime: 7d
    ```

    1.  Sprout's configuration and database is under `/sprout`.

=== "Docker Run"

    ```sh linenums="1"
    docker run -d \
      --name=sprout \
      -v /appdata/sprout:/sprout \ # (1)!
      -p 80:80 \
      -e TZ=America/New_York \
      -e sprout_providers_simpleFIN_accessToken=${SIMPLE_FIN_ACCESS_URL} \
      -e sprout_server_jwtExpirationTime=7d \
      --restart unless-stopped \
      croudebush/sprout:stable
    ```

    1.  Sprout's configuration and database is under `/sprout`.

## Docker Images

Sprout offers [Docker images](https://hub.docker.com/r/croudebush/sprout) to suit different needs.

-   `croudebush/sprout:stable`: **(Recommended)** This is the image for most users. It is only updated with tagged, stable releases from the `main` branch.
-   `croudebush/sprout:dev`: This image is tied directly to the `main` branch and updates with every commit. Use this for testing the latest features, but expect potential instability.
