# Security Policy

## Supported Versions

To streamline maintenance and ensure maximum security for your self-hosted data, we officially support **only the latest major release** of Sprout.

When a new major version is released, the previous major version enters an immediate end-of-life (EOL) status. We strongly recommend configuring your container orchestrator (e.g., Portainer, or Docker Compose) to track stable releases and updating regularly to ensure you are running the most secure build.

## Our Security Commitment

Sprout is dedicated to providing a secure environment for self-hosted financial management. Because Sprout handles private transactional, currency, and financial data, security is our top priority.

Our core architecture incorporates:

- **OpenID Connect (OIDC) Integration:** Delegating authentication to trusted, secure identity providers (such as Authelia) to ensure secure single sign-on (SSO) and robust token-based session management.
- **Secure External API Consumption:** Masking and securely handling external connections (such as Brandfetch integration) without exposing client-side credentials or sensitive identifiers.
- **Robust Monorepo Testing:** Continuous integration via GitHub Actions executing automated security and unit test suites (using Jest) and tracking test coverage via Codecov to prevent regression bugs.

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.** If you discover a security vulnerability within Sprout, please report it responsibly using our private disclosure process.

### How to Submit a Report

1. Send an email to the [project maintainer](https://github.com/cameronroudebush/).
2. Include a detailed description of the vulnerability, including:
    - The specific component or endpoint affected (e.g., Backend API, OIDC Callback, etc.).
    - Detailed steps to reproduce the issue (a proof-of-concept script, request payload, or step-by-step UI actions).
    - The potential impact if exploited (e.g., privilege escalation, data leakage).
3. If applicable, specify the version of Sprout and the environmental setup (e.g., Docker deployment, proxy layer like Traefik) where the vulnerability was observed.

### Our Response Process

- **Acknowledgement:** You will receive an email acknowledgement within **5 days** of your submission.
- **Investigation:** We will investigate the finding, validate the exploit, and determine its scope and severity.
- **Coordination:** We will keep you updated on our progress as we work toward a resolution.
- **Fix & Disclosure:** Once a patch is developed and verified via our CI/CD pipeline, it will be released in a new update.

## Best Practices for Self-Hosting Sprout

To maximize the security of your Sprout deployment, we strongly recommend implementing the following infrastructure guidelines:

1.  **Strict Authentication:** Always enable OpenID Connect (OIDC) integration via a local identity provider like **Authelia**. Avoid running the application exposed to the public internet without a robust multi-factor authentication (MFA) layer.
2.  **Reverse Proxy Protection:** Deploy Sprout behind a secure reverse proxy such as **Traefik**. Ensure TLS certificates are enforced with modern.
3.  **Network Isolation:** Isolate your Sprout frontend, backend, and auxiliary caching services (like **Redis**) inside a dedicated, non-public Docker bridge network. Do not expose database or Redis ports directly to the host machine or public router ports.
4.  **Environment Variables:** Keep all secrets (`JWT_SECRET`, `OIDC_CLIENT_SECRET`, external API tokens) secured inside a non-committed `.env` file or passed securely via your container orchestrator settings.
