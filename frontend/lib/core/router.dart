// GoRouter configuration
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/account/dialog/add_account.dart';
import 'package:sprout/account/overview.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/account/widgets/account.dart';
import 'package:sprout/auth/provider.dart';
import 'package:sprout/category/provider.dart';
import 'package:sprout/category/widgets/dropdown.dart';
import 'package:sprout/category/widgets/info.dart';
import 'package:sprout/category/widgets/overview.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/home.dart';
import 'package:sprout/core/models/page.dart';
import 'package:sprout/core/provider/init.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/shell.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/connect_fail.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/setup/connection_setup.dart';
import 'package:sprout/setup/setup.dart';
import 'package:sprout/transaction-rule/widgets/rule_info.dart';
import 'package:sprout/transaction-rule/widgets/rule_overview.dart';
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
          onSetupSuccess: () async {
            await configProvider.populateUnsecureConfig();
            // Grab all updated data
            await InitializationNotifier.initializeWithNotification((status) {});
            SproutNavigator.redirect("home");
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
    SproutPage((context, state) => HomePage(), 'Home', icon: Icons.home, showOnBottomNav: true),
    // Accounts
    SproutPage(
      (context, state) {
        final accType = state.uri.queryParameters["acc-type"];
        return AccountsOverview(defaultAccountType: accType);
      },
      'Accounts',
      icon: Icons.account_balance,
      showOnBottomNav: true,
      pagePadding: 0,
      scrollWrapper: false,
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
    ),
    // Singular account
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
      scrollWrapper: false,
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
    // Transactions
    SproutPage(
      (context, state) {
        final provider = ServiceLocator.get<CategoryProvider>();
        final categoryId = state.uri.queryParameters["cat"];
        final category = categoryId == "unknown"
            ? "unknown"
            : provider.categories.firstWhereOrNull((c) => c.id == categoryId) ?? CategoryDropdown.fakeAllCategory;
        return TransactionsOverview(initialCategoryFilter: category);
      },
      'Transactions',
      icon: Icons.receipt,
      showOnBottomNav: true,
      scrollWrapper: false,
    ),
    SproutPage(
      (context, state) => TransactionRuleOverview(),
      'Rules',
      icon: Icons.rule,
      buttonBuilder: (context, isDesktop) {
        return
        // Add button
        SproutTooltip(
          message: "Add a new transaction rule",
          child: IconButton(
            onPressed: () => showDialog(context: context, builder: (_) => TransactionRuleInfo(null)),
            icon: Icon(Icons.add),
            style: AppTheme.primaryButton,
          ),
        );
      },
    ),
    SproutPage(
      (context, state) => CategoryOverview(),
      'Categories',
      icon: Icons.category,
      buttonBuilder: (context, isDesktop) {
        return SproutTooltip(
          message: "Add Category",
          child: IconButton(
            onPressed: () => showDialog(context: context, builder: (_) => CategoryInfo(null)),
            icon: const Icon(Icons.add),
            style: AppTheme.primaryButton,
          ),
        );
      },
    ),
    // Subscriptions
    SproutPage(
      (context, state) => TransactionMonthlySubscriptions(),
      'Subscriptions',
      icon: Icons.subscriptions,
      showOnBottomNav: true,
    ),
    // Settings
    SproutPage((context, state) => UserPage(), 'Settings', icon: Icons.settings, showOnSideNav: false),
  ];

  /// A list of all pages in order including sub pages
  static final allPagesInOrder = SproutRouter.pages.toList();

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
      if (setupPosition == "welcome") return "/setup";

      // Check if we're already authenticated (JWT or not)
      if (!authProvider.isLoggedIn) return "/login";

      // If we're already logged in and somehow going back to login, kick them back to home
      final isGoingToLogin = state.matchedLocation == '/login';
      if (authProvider.isLoggedIn && isGoingToLogin) {
        return '/';
      }

      // No case hit? Don't redirect
      return null;
    },
    // Generate routes from pages
    routes: SproutRouter.pages.map((page) => _routeFromPage(page)).toList(),
  );

  /// Generates the route for the given page
  static GoRoute _routeFromPage(SproutPage page) {
    return GoRoute(
      name: page.label.toLowerCase(),
      path: page.path,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: SproutShell(
          currentPage: page,
          renderAppBar: page.renderAppBar,
          renderNav: page.renderNav,
          child: page.page(context, state),
        ),
      ),
    );
  }
}
