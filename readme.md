<p align="center">
  <img width="50%" src="./frontend/assets/logo/color-transparent.svg">
</p>

> [!caution]
> This application is in **_active_** development. We do not make any guarantees about capability, database retention, or security. Note that while this will improve with time, we are not to our 1.0 release yet.
>
> **_Use at your own risk_**

# What is Sprout?

Sprout is a financial management app specializing in automatic transaction tracking using various financial API's.

# How do I use Sprout?

TODO

# Building Sprout for releases

We highly recommend using docker to deploy sprout as everything is easily contained. To build sprout execute:

`npm run build:docker`

This script will automatically handle tagging docker containers and doing any other required capabilities.

# How do I contribute to Sprout?

TODO

## Configuration

The configuration file is generated dynamically and placed directly next to the executable under `sprout.config.yml`. You can see in this .yml file that most of the features are commented and you can use them how you see fit.

TODO - Config file and env variables

### Environment Variables

Environment variables are supported within the docker build and even in the executable. The top of the `sprout.config.yml` tells you how to modify each specific config field listed in [configuration](#configuration). Below are some common examples:

```env
TZ=America/New_York
sprout_server_port=9000
sprout_server_jwtExpirationTime=30m
sprout_providers_simpleFIN_accessToken=MY_ACCESS_TOKEN
```

TZ
