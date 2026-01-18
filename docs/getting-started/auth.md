---
title: Authentication Strategies
description: Learn about the authentication capabilities of Sprout.
---

# Authentication Strategies

Sprout supports two methods of authentication to ensure your data remains secure while providing flexibility for different hosting environments.

## Local Authentication (local)

-   The Local strategy is the **default** and simplest method. It is designed for **single-user** instances (typically the administrator).
-   How it works: Sprout issues and signs its own JSON Web Tokens (JWTs) internally.
-   Access: This mode only allows for a single user account and utilizes the API endpoints for login.

## OIDC Authentication (oidc)

The OpenID Connect (OIDC) strategy is recommended for power users or organizations that want to allow **multiple users** to access Sprout using an existing identity provider (like Authelia, Keycloak, or Google).
Understanding OIDC Security

-   OAuth2 / OIDC: These are industry-standard protocols that allow Sprout to verify your identity without ever seeing your password. Sprout "trusts" your identity provider to handle the login.
-   JWKS (JSON Web Key Set): Sprout uses the jwks_uri endpoint from your provider to cryptographically verify that the login token is legitimate and hasn't been tampered with.
-   Multi-User Support: Unlike local auth, OIDC allows any user authorized by your provider to log into Sprout.
-   Auto-Provisioning: First-time users arriving via OIDC will be automatically prompted to set up their Sprout profile upon their first successful login.

### Example Authelia Configuration

To use OIDC with a provider like Authelia, you would add Sprout to your configuration.yml as a client:

```yaml linenums="1" title="authelia.config.yml"
identity_providers:
    oidc:
        clients:
            - id: sprout
              description: Sprout
              public: true
              authorization_policy: two_factor
              redirect_uris:
                  - net.croudebush.sprout://auth_callback # Mobile
                  - http://sprout.mydomain.com/auth_callback.html # Web (Change to your production URL)
              scopes:
                  - openid
                  - email
                  - profile
              response_types:
                  - code
                  - id_token token
              grant_types:
                  - implicit
                  - authorization_code
```

!!! note

    To enable this strategy, you must configure the OIDC via the configuration guide. For more info on how to configure sprout, please see here the **[Configuration](./configuration.md)** guide.
