// GoRouter configuration
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/account/dialog/add_account.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/account/overview.dart';
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
    ),
    // Connection Setup
    SproutPage(
      (context, state) => ConnectionSetup(),
      'Connection Setup',
      icon: Icons.settings_backup_restore,
      renderNav: false,
      scrollWrapper: false,
    ),
    // Connection Fail
    SproutPage(
      (context, state) => FailToConnectWidget(),
      'Connection Failure',
      icon: Icons.settings_backup_restore,
      renderNav: false,
      scrollWrapper: false,
    ),
    // Home
    SproutPage((context, state) => HomePage(), 'Home', icon: Icons.home),
    // Accounts
    SproutPage(
      (context, state) => AccountsOverview(),
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
            final Account? account = state.extra as Account?;
            if (account == null) {
              return const Text('Error: Account not found');
            }
            return AccountWidget(account);
          },
          'Account',
          icon: Icons.account_balance_wallet,
          canNavigateTo: false,
          buttonBuilder: (context, isDesktop) {
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
                        onPressed: () => SproutNavigator.redirect("accounts"),
                        label: TextWidget(text: "Back to accounts"),
                      ),
                    if (!isDesktop)
                      IconButton(onPressed: () => SproutNavigator.redirect("accounts"), icon: Icon(Icons.arrow_back)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),

    // Transactions
    SproutPage((context, state) => TransactionsOverviewPage(), 'Transactions', icon: Icons.receipt),
    // Settings
    SproutPage((context, state) => UserPage(), 'Settings', icon: Icons.settings),
  ];

  /// A list of all pages in order including sub pages
  static final allPagesInOrder = SproutRouter.pages.map((e) => [e, ...?e.subPages]).expand((e) => e).toList();

  /// A list of navigator keys, one for each branch. This is crucial for preserving
  /// the navigation stack state of each branch when switching between them.
  static final branchNavigatorKeys = pages.map((_) => GlobalKey<NavigatorState>()).toList();

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
            navigationShell: navigationShell,
            currentPage: currentPage,
            renderAppBar: currentPage.renderAppBar,
            renderNav: currentPage.renderNav,
          );
        },
        branches: SproutRouter.pages.asMap().entries.map((entry) {
          final index = entry.key;
          final top = entry.value;
          return StatefulShellBranch(
            navigatorKey: branchNavigatorKeys[index],
            routes: [
              // Top level route
              GoRoute(
                name: top.label.toLowerCase(),
                path: top.path,
                pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: top.page(context, state)),
              ),
              // Sub routes
              if (top.subPages != null)
                ...top.subPages!.map(
                  (sub) => GoRoute(
                    name: sub.label.toLowerCase(),
                    path: sub.path,
                    pageBuilder: (context, state) =>
                        NoTransitionPage(key: state.pageKey, child: sub.page(context, state)),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    ],
  );
}
