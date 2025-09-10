// GoRouter configuration
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/account/dialog/add_account.dart';
import 'package:sprout/account/overview.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/account/widgets/account.dart';
import 'package:sprout/auth/provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/home.dart';
import 'package:sprout/core/models/page.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/shell.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/connect_fail.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/holding/overview.dart';
import 'package:sprout/setup/connection_setup.dart';
import 'package:sprout/setup/setup.dart';
import 'package:sprout/transaction/monthly.dart';
import 'package:sprout/transaction/overview.dart';
import 'package:sprout/user/login.dart';
import 'package:sprout/user/user.dart';

/// Router information for our app
class SproutRouter {
  /// All pages available to the app for navigating between
  static final pages = [
    // Login
    SproutPage(
      (context, state) => LoginPage(),
      'Login',
      icon: Icons.login,
      renderAppBar: false,
      renderNav: false,
      scrollWrapper: false,
    ),
    // Setup
    SproutPage(
      (context, state) {
        final configProvider = ServiceLocator.get<ConfigProvider>();
        return SetupPage(
          onSetupSuccess: () {
            configProvider.populateUnsecureConfig();
          },
        );
      },
      'Setup',
      icon: Icons.settings_backup_restore,
      renderNav: false,
      useFullLogo: true,
    ),
    // Connection Setup
    SproutPage(
      (context, state) => ConnectionSetup(),
      'Connection Setup',
      icon: Icons.settings_backup_restore,
      renderNav: false,
      scrollWrapper: false,
      useFullLogo: true,
      preserveState: false,
    ),
    // Connection Fail
    SproutPage(
      (context, state) => FailToConnectWidget(),
      'Connection Failure',
      icon: Icons.settings_backup_restore,
      renderNav: false,
      renderAppBar: false,
      scrollWrapper: false,
    ),
    // Home
    SproutPage((context, state) => HomePage(), 'Home', icon: Icons.home),
    // Accounts
    SproutPage(
      (context, state) {
        final accType = state.uri.queryParameters["acc-type"];
        return AccountsOverview(defaultAccountType: accType);
      },
      'Accounts',
      icon: Icons.account_balance,
      buttonBuilder: (BuildContext context, bool isDesktop) {
        return Row(
          children: [
            // Add account button
            SproutTooltip(
              message: "Add an account",
              child: IconButton(
                style: isDesktop ? AppTheme.primaryButton : null,
                onPressed: () async {
                  // Open the add account dialog
                  await showDialog(context: context, builder: (_) => const AddAccountDialog());
                },
                icon: Icon(Icons.add),
              ),
            ),
          ],
        );
      },
      subPages: [
        SproutPage((context, state) => HoldingsOverview(), 'Holdings', icon: Icons.stacked_line_chart_rounded),
        SproutPage(
          (context, state) {
            final accountProvider = ServiceLocator.get<AccountProvider>();
            final accountId = state.uri.queryParameters["acc"];
            final account = accountProvider.linkedAccounts.firstWhereOrNull((x) => x.id == accountId);
            if (account == null) {
              return const Text('Error: Account not found');
            }
            return AccountWidget(account);
          },
          'Account',
          icon: Icons.account_balance_wallet,
          canNavigateTo: false,
          buttonBuilder: (context, isDesktop) {
            final accountProvider = ServiceLocator.get<AccountProvider>();
            final state = GoRouter.of(context).state;
            final accountId = state.uri.queryParameters["acc"];
            final account = accountProvider.linkedAccounts.firstWhereOrNull((x) => x.id == accountId);
            void redirect() => SproutNavigator.redirect("accounts", queryParameters: {"acc-type": account?.type});
            // Back to accounts
            return Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.only(left: isDesktop ? 24 : 0),
                child: Row(
                  children: [
                    if (isDesktop)
                      FilledButton.icon(
                        icon: Icon(Icons.arrow_back),
                        style: AppTheme.primaryButton,
                        onPressed: redirect,
                        label: TextWidget(text: "Back to accounts"),
                      ),
                    if (!isDesktop) IconButton(onPressed: redirect, icon: Icon(Icons.arrow_back)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),

    // Transactions
    SproutPage(
      (context, state) => TransactionsOverviewPage(),
      'Transactions',
      icon: Icons.receipt,
      subPages: [
        SproutPage((context, state) => TransactionMonthlySubscriptions(), 'Subscriptions', icon: Icons.subscriptions),
      ],
    ),
    // Settings
    SproutPage((context, state) => UserPage(), 'Settings', icon: Icons.settings),
  ];

  /// A list of all pages in order including sub pages
  static final allPagesInOrder = SproutRouter.pages.map((e) => [e, ...?e.subPages]).expand((e) => e).toList();

  /// The router for navigation around Sprout
  static final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final configProvider = ServiceLocator.get<ConfigProvider>();
      final authProvider = ServiceLocator.get<AuthProvider>();

      // Check if we don't have a connection url
      final hasConnectionUrl = configProvider.api.client.hasConnectionUrl();
      if (!hasConnectionUrl) return "/connection-setup";

      // Check if we failed to connect
      final failedToConnect = configProvider.failedToConnect;
      if (failedToConnect) return "/connection-failure";

      // Check if this is first time setup
      final setupPosition = configProvider.unsecureConfig?.firstTimeSetupPosition;
      if (setupPosition == null) return "/setup";

      // Check if we're already authenticated (JWT or not)
      if (!authProvider.isLoggedIn) return "/login";

      // No case hit? Don't redirect
      return null;
    },
    // Generate routes from pages
    routes: [
      // Add routes that we don't want to maintain state of
      ...SproutRouter.pages
          .where((e) => !e.preserveState)
          .map((e) {
            SproutShell childOverride(BuildContext context, GoRouterState state) =>
                SproutShell(currentPage: e, child: e.page(context, state));
            return _routesFromPage(e, childOverride: childOverride);
          })
          .expand((e) => e),
      // Use an index stack for every page that requires a shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final String? currentPath = state.fullPath;
          final SproutPage currentPage = allPagesInOrder.firstWhere(
            (p) => p.path == currentPath,
            // As a fallback, use the top-level page of the current branch. This is a safe default.
            orElse: () => pages[navigationShell.currentIndex],
          );

          return SproutShell(
            currentPage: currentPage,
            renderAppBar: currentPage.renderAppBar,
            renderNav: currentPage.renderNav,
            child: navigationShell,
          );
        },
        branches: SproutRouter.pages.where((e) => e.preserveState).mapIndexed((index, top) {
          return StatefulShellBranch(routes: _routesFromPage(top));
        }).toList(),
      ),
    ],
  );

  /// Generates the route for the given page
  static List<GoRoute> _routesFromPage(
    SproutPage page, {
    Widget Function(BuildContext context, GoRouterState state)? childOverride,
  }) {
    final mainRoute = GoRoute(
      name: page.label.toLowerCase(),
      path: page.path,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: childOverride != null ? childOverride(context, state) : page.page(context, state),
      ),
    );
    final subRoutes = page.subPages?.expand((e) => _routesFromPage(e)).toList();
    return [mainRoute, ...?subRoutes];
  }
}
