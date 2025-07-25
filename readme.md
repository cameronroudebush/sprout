<p align="center">
  <img width="50%" src="./frontend/assets/logo/color-transparent.svg">
</p>

> [!caution]
> This application is in **_active_** development. We do not make any guarantees about capability, database retention, or security. Note that while this will improve with time, we are not to our 1.0 release yet.
>
> **_Use at your own risk_**

# What is Sprout?

Sprout is a financial management app specializing in automatic account tracking using various financial API's.

![Sprout Home Page](/docs/images/home.png "Sprout Home Page")
![Sprout Accounts Page](/docs/images/accounts.png "Sprout Accounts Page")

## Code Base

Sprout is designed with a "mobile first" approach utilizing flutter for it's interfaces with a node.js backend.

## Planed Features

Below is a list of planned features I personally would find beneficial. I make no guarantees on when these will be implemented but I am working on them.

- Redesigned Interfaces
  - Home Page
    - Show an improved simplified net worth for the past month
    - Show simplified transactions of maybe the last N number of transactions
  - Accounts Page
    - Adding improved account views for details of each account
      - Things like transactions for this account, net worth over time, etc.
    - Centralized chart at the top
      - Allow the ability to select time frames to look back at net worth over time
  - Overhauled Transactions
    - Update the table display to be a bit more friendly
    - Allow editing the transactions category
      - Automatic rules for these edits?
  - Holdings page
    - Real time stock ticket updates
    - Show each account separately, the holdings associated to them, and the % change for today.
    - TBD.
- User Configuration
  - Add OIDC support
  - Improved User management
    - Allow additional user creation
      - Allow each user to have their own SimpleFIN access URL.
  - Password resets (I should have probably started with this).
  - Various config options:
    - Allow users to hide their balances from display
- Improved desktop mode
  - Move the bottom nav to a sidenav
- Additional providers
  - Zillow for house value over time?
  - Crypto? (This will be a pain)
- Android/IOS Apps
  - Widgets for things like transactions

# How do I use Sprout?

The recommended way to use sprout is as a docker image. To get started, see below:

```yml
sprout:
  container_name: sprout
  image: croudebush/sprout:stable
  volumes:
    # The database .sqlite file will be stored in /sprout
    - /mnt/user/appdata/sprout:/sprout
  ports:
    - 80:80
  restart: unless-stopped
  environment:
    TZ: America/New_York
    sprout_providers_simpleFIN_accessToken: ${SIMPLE_FIN_ACCESS_URL}
    sprout_server_jwtExpirationTime: 7d
```

After launching the above docker compose, you'll be able to navigate to your browser on the same machine to `http://localhost` and you'll see sprout's setup.

## Available Images:

- `croudebush/sprout:stable`
  - This is the recommended image that will only be updated with tagged releases on the main branch.
- `croudebush/sprout:dev`
  - This is directly tied to the main branch and will update every time a commit is pushed.

## Configuration

The configuration file is generated dynamically and placed directly next to the executable under `sprout.config.yml`. You can see in this .yml file below the available options with definitions.

```yml
# Configuration for the various providers
providers:
  # SimpleFIN configuration: https://www.simplefin.org/
  simpleFIN:
    # This access token is acquired from SimpleFIN that allows us to authenticate and grab your data.
    # You'll need to go to this link to get one configured:
    # https://beta-bridge.simplefin.org/info/developers
    accessToken:
    # How many days to look back for transactional data.
    lookBackDays: 7
    # How many API calls we allow per day for this provider.
    rateLimit: 24

# Core server config options
server:
  # The port to accept backend requests on.
  port: 8001
  # How long JWT's should stay valid for users
  jwtExpirationTime: 30m

# Database specific options
database:
  # The type of database we want to use
  # Must be one of: [sqlite]
  type: sqlite
  # SQLite specific configuration options
  sqlite:
    # Database file name
    database: sprout.sqlite

# How often to perform data queries for data from providers. Default is once a day at 7am.
updateTime: 0 7 * * *
```

### Environment Variables

Environment variables are supported within the docker build and even in the executable. The top of the `sprout.config.yml` tells you how to modify each specific config field listed in [configuration](#configuration). Below are some common examples:

```env
TZ=America/New_York
sprout_server_port=9000
sprout_server_jwtExpirationTime=30m
sprout_providers_simpleFIN_accessToken=MY_ACCESS_TOKEN
```

# Contributions

We welcome contributions from the community! Whether you're fixing bugs, adding new features, improving documentation, or simply reporting issues, your help is greatly appreciated.
