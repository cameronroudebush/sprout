// GoRouter configuration
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/account/widgets/account.dart';
import 'package:sprout/account/widgets/account_overview.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/cash-flow/widgets/overview.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/dropdown.dart';
import 'package:sprout/category/widgets/overview.dart';
import 'package:sprout/chat/widgets/chat.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/home.dart';
import 'package:sprout/core/models/page.dart';
import 'package:sprout/core/provider/init.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/shell.dart';
import 'package:sprout/core/widgets/connect_fail.dart';
import 'package:sprout/setup/setup.dart';
import 'package:sprout/setup/widgets/connection_setup.dart';
import 'package:sprout/transaction-rule/widgets/rule_overview.dart';
import 'package:sprout/transaction/widgets/monthly.dart';
import 'package:sprout/transaction/widgets/overview.dart';
import 'package:sprout/user/widgets/login.dart';
import 'package:sprout/user/widgets/user_config.dart';

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
      pagePadding: 0,
    ),
    // Setup
    SproutPage(
      (context, state) {
        final configProvider = ServiceLocator.get<ConfigProvider>();
        final authProvider = ServiceLocator.get<AuthProvider>();
        return SetupPage(
          onSetupSuccess: () async {
            authProvider.isSetupMode = false;
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
        final String? accTypeString = state.uri.queryParameters["acc-type"];
        final AccountTypeEnum? accType = accTypeString != null
            ? AccountTypeEnum.values.firstWhereOrNull((e) => e.value == accTypeString)
            : null;
        return AccountsOverview(defaultAccountType: accType);
      },
      'Accounts',
      icon: Icons.account_balance,
      showOnBottomNav: true,
      pagePadding: 0,
      scrollWrapper: false,
    ),
    // Singular account
    SproutPage(
      (context, state) {
        final accountId = state.uri.queryParameters["acc"];
        if (accountId == null) return const Text('Error: Account not found');
        return AccountWidget(accountId);
      },
      'Account',
      icon: Icons.account_balance_wallet,
      canNavigateTo: false,
      scrollWrapper: false,
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
    SproutPage((context, state) => TransactionRuleOverview(), 'Rules', icon: Icons.rule),
    SproutPage((context, state) => CategoryOverview(), 'Categories', icon: Icons.category),
    // Subscriptions
    SproutPage((context, state) => TransactionMonthlySubscriptions(), 'Subscriptions', icon: Icons.subscriptions),
    // Cash Flow
    SproutPage(
      (context, state) => CashFlowOverview(),
      'Cash Flow',
      icon: Icons.bar_chart,
      showOnBottomNav: true,
      scrollWrapper: false,
    ),
    // Settings
    SproutPage((context, state) => UserConfigPage(), 'Settings', icon: Icons.settings, showOnSideNav: false),
    // Chat
    SproutPage(
      (context, state) => Chat(),
      'Chat',
      icon: Icons.auto_awesome,
      showOnBottomNav: true,
      scrollWrapper: false,
    ),
  ];

  /// A list of all pages in order including sub pages
  static final allPagesInOrder = SproutRouter.pages.toList();

  /// The router for navigation around Sprout
  static final router = GoRouter(
    navigatorKey: SproutNavigator.key,
    initialLocation: '/login',
    observers: [ServiceLocator.routeObserver],
    redirect: (context, state) {
      final configProvider = ServiceLocator.get<ConfigProvider>();
      final authProvider = ServiceLocator.get<AuthProvider>();

      // Check if we don't have a connection url
      final hasConnectionUrl = configProvider.hasConnectionUrl();
      if (!hasConnectionUrl) return "/connection-setup";

      // Check if we failed to connect
      final failedToConnect = configProvider.failedToConnect;
      if (failedToConnect) return "/connection-failure";

      // Force setup if we're in setup mode
      if (authProvider.isSetupMode) return "/setup";

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
