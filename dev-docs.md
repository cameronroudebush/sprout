TODO:

- Add a table for transactions
  - Keep cleaning this up
  - Dynamic table size?
  - Maybe some relevant metrics of what the transactions are of?
- Maybe centralize the card display otherwise?
- Centralize tooltips and apply styling
- Auto logout on unauthroized envocations
- Transactions
- Holdings
  - There is a site that exists that handles getting icons for relevant holdings
- Add manual sync button
  - SSE to tell to refresh data on schedule runs?
- Implement actual models instead of dynamic objects.
  - Come up with a more generic way to do this then my hard coding.
- Net worth notifications?
- Add info to show who the provider is that the app is currently using
  - Maybe let this get configured during setup?
    - We'd need to store this in the db...
- Add user config info
  - Password reset?
  - OIDC?
- Add Coinbase & Zillow providers
  - Maybe move how you config the simpleFin provider
- Synthfinance attribution
  - Also logo loading warning: https://github.com/flutter/flutter/issues/163288

Unrelated:

- My compose files need moved to github as a backup
