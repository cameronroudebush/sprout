

Here's what's new in version <b>Unreleased</b>:


✨ <b>New Features</b>

- (subscription): Adding a subscription calendar
-  Various account improvements
- (router): Implementing a real router
- (account): Beginning account overhaul
-  Adding check for manual account syncing
- (provider): Massive provider improvements
-  Various improvements
- (android): Add android app support
- (pages): Beginning to add support for Sprouts GitHub Pages display
-  Add holding history


🐞 <b>Bug Fixes</b>

- (net-worth): Remove IQR as it is causing day over day change calculation issues
- (login): Correct login process
-  Various bugfixes
-  Mobile displays
- (ci): Adjusting android CI, again...
-  More android CI adjustments
- (ci): Adjust aab reference path
- (ci): Adjust android to use properly authenticated google steps
- (ci): Correct issues with dockerfile being out of date for flutter version
- (them): Overhauling theme
- (ci): Correct android env issues
- (ci): Update android process to produce qa track release
-  Correcting net worth calcs
- (ci): Completing release pipeline
- (ci): Correct missing LFS in checkout, again
-  Correct SSE casting
-  Various improvements
- (app): Correct issues in android app
- (ci): Correct builds
-  Update pages location
-  Move where pages are located


Here's what's new in version <b>v0.0.4</b>:




🐞 <b>Bug Fixes</b>

- (net-worth): Fixing more net worth calculations
- (db): Correct race condition where the configuration wasn't loaded when the database is initialized


Here's what's new in version <b>v0.0.3</b>:


✨ <b>New Features</b>

- (ci): Improve workflow to auto create a draft release
- (database): Adding database migrations
- (holding): Cleaning up the holding display on mobile
- (holding): Starting to add functional holding displays
- (transactions): Overhauling transactions and adding charts
- (transactions): Adding new transactions display
-  Accounts & Home overhaul
- (jobs): Separating jobs out some more
- (database): Adding db backups


🐞 <b>Bug Fixes</b>

-  Correcting how the app behaves when it has no data loaded
- (database): Correct issues with new databases being created
- (sync): Correcting issues with account history
- (dev): Correct SSE's not being cleaned up on hot reload
-  Bottom nav and formatters
- (sync): Correct holding error
-  Transaction & net worth
- (chart): Fixing line chart to properly be generic
- (rate-limit): Correct rate limiting issues with provider
- (buttons): Correcting their default sizing with relative screen sizing
-  Readme and backups
- (account): Update selectable accounts to not have overlaping selection borders


Here's what's new in version <b>v0.0.2</b>:




🐞 <b>Bug Fixes</b>

- (ci): Correct an issue where LFS was excluded from the builds
- (database): Correct a basic migration issue


Here's what's new in version <b>v0.0.1</b>:


✨ <b>New Features</b>

-  Faking the demo data to include random other accounts
- (config): Adding user configuration
- (ci): Build updates
- (ci): Updating some CI
- (ci): Re-condensing files
- (proxy): Image proxy is now secured
- (account): Updating some various displays of accounts
- (accounts): Overhaul
- (nav): Updating part of the app bar
- (accounts): Adding an improved accounts page
- (snackbar): Adding styled snackbars
- (accounts): Improve image proxy
- (account): Add account error handling
- (transactions): Improving transactions display
-  API and Provider bases
- (sse): Adding initial sse support
- (version): Add a frontend version display for now
- (transaction): Improving transaction display
- (transactions): Starting to add transactions
- (account): Improving accounts display
- (disconnect): Adding some better handling when the backend can't be connected to
- (schedule): Add schedule status to frontend for display
- (net): Improving net worth display
-  Various improvements
- (autofill): Add autofill
- (accounts): Adding account add support
- (accounts): Improving account display
- (api): Adding more API
-  Setup and login
-  Starting to add login
-  Adding new flutter frontend
-  Improving backend scheduler and endpoints
-  Scheduler updates
- (transaction): Updating transactions to use syncing


🐞 <b>Bug Fixes</b>

-  Readme casing
- (ci): Correcting token reference
- (ci): Working on actions
- (ci): Adjust action from miss-type
- (image-proxy): Remove synth usage as it's been discontinued
- (sse): Bug in sse where it tries to reconnect even with auth failures
- (auth): Logout now cleans up data from providers
-  Various fixes
- (transaction): Correct nullable category in frontend
- (version): Update version displays so only the app details now shows the difference in versions
- (accounts): Correct icons display
- (transaction): Correct frontend not allowing null categories
- (dockerfile): Correct issue with frontend failing to have a version
-  Various fixes
- (transaction): Update transaction to allow nullable category
- (transaction): Monthly display to scale better
- (transaction): Correct epoch of start for transactions
- (account): Finalize reorganization of accounts code
- (cache): Correcting cache buster by applying versions from git-describe
-  Transaction and accounts
-  Correct schedule and time zones
- (schedule): Hopefully updating background schedule
-  Other random fixes
- (scheduler): Correct issue in institutions not updating
-  Hopefully fixing autofill
-  Styling changes
- (accounts): Correcting issues with account scroll-ability
-  Downscale icon
-  Correct various build issues
-  Correcting build time issues
-  Builds


Here's what's new in version <b>v0.0.1-beta</b>:




