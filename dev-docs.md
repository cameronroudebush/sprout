TODO:

- Add SSE to tell frontend to refresh data

  - Have logouts clean up SSE
    - And other components
  - For things like syncs
  - Move the central re-sync function into some more generic capability to auto refresh
    - Probably add a base abstract class for my providers and do something with that.

- Easier way to refresh accounts that need re-authenticated
- Accounts page
  - Show separate net-worth charts
- Centralize tooltips and apply styling
- Centralize spinners to better scale them
- Auto logout on unauthorized evocations
  - Better handling of API error messages in general could be a good idea.
- Holdings
- Bottom bar to sidenav on larger screens
- Net worth notifications?
- Add user config info
  - Password reset?
  - OIDC?
- Add Coinbase & Zillow providers
  - Maybe move how you config the simpleFin provider
- Lots and lots of docs...

Unrelated:

- My compose files need moved to github as a backup
