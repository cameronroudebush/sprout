# Configuration

The configuration file, `sprout.config.yml`, is generated dynamically and placed next to the executable inside the container. Below are the available options with definitions.

## Full Configuration

```yaml linenums="1" title="sprout.config.yml"
providers:
    # How often to perform data queries for data from providers. Default is once a day at 7am.
    updateTime: 0 7 * * *
    # SimpleFIN configuration: https://www.simplefin.org/
    simpleFIN:
        # This access token is acquired from SimpleFIN.
        # Get one here: https://beta-bridge.simplefin.org/info/developers
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
    # Configuration for performing database backups automatically
    backup:
        enabled: true
        count: 30
        time: 0 4 * * *
        directory: /backups/database
    # Must be one of: [sqlite]
    type: sqlite
    sqlite:
        database: sprout.sqlite

# Settings specific to transactions
transaction:
    # When to check for stuck transactions. This includes things like stuck pending.
    stuckTransactionTime: 0 3 * * *
```

## Environment Variables

Environment variables are supported to make it easier to not have to keep track of the config file manually. Use the prefix `sprout_` followed by the config path. Here are some common examples.

```yaml
TZ: America/New_York
sprout_server_port: 9000
sprout_server_jwtExpirationTime: 7d
sprout_providers_simpleFIN_accessToken: MY_ACCESS_TOKEN
```

You can see more of these examples in the [setup guide](../getting-started/configuration.md).
