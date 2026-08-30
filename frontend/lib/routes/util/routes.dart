import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/routes/account_details.dart';
import 'package:sprout/routes/accounts.dart';
import 'package:sprout/routes/categories.dart';
import 'package:sprout/routes/chat.dart';
import 'package:sprout/routes/dashboard.dart';
import 'package:sprout/routes/holdings.dart';
import 'package:sprout/routes/reports.dart';
import 'package:sprout/routes/settings.dart';
import 'package:sprout/routes/subscriptions.dart';
import 'package:sprout/routes/transaction_rules.dart';
import 'package:sprout/routes/transactions.dart';
import 'package:sprout/routes/util/route.dart';

/// List of routes that require authentication
final List<SproutRoute> authenticatedRoutes = [
  SproutRoute(
    path: '/',
    label: 'Dashboard',
    icon: Icons.dashboard_rounded,
    bottomNavPriority: 0,
    builder: (context, state) => const DashboardPage(),
  ),
  SproutRoute(
      path: '/accounts',
      label: 'Accounts',
      icon: Icons.account_balance,
      category: 'Banking',
      builder: (context, state) => const AccountsPage(),
      routes: [
        SproutRoute(
          path: '/:id',
          label: 'Account Details',
          icon: Icons.account_balance_wallet,
          category: 'Banking',
          showInSidebar: false,
          builder: (context, state) {
            final accountId = state.pathParameters['id'];
            return AccountDetailsPage(accountId: accountId);
          },
        ),
      ]),
  SproutRoute(
    path: '/chat',
    label: 'Chat',
    icon: Icons.auto_awesome,
    bottomNavPriority: 2,
    builder: (context, state) => const ChatPage(),
    enabled: (secureConfig, unsecureConfig, userConfig) =>
        unsecureConfig.demoMode != null || (secureConfig.chatEnabled && (userConfig?.includeAICapabilities ?? false)),
  ),
  SproutRoute(
    path: '/transactions',
    label: 'Transactions',
    icon: Icons.receipt,
    bottomNavPriority: 3,
    category: 'Banking',
    builder: (context, state) => const TransactionsPage(),
  ),
  SproutRoute(
    path: '/holdings',
    label: 'Holdings',
    icon: Icons.show_chart,
    bottomNavPriority: 5,
    category: 'Investments',
    builder: (context, state) => const HoldingsPage(),
  ),
  SproutRoute(
    path: '/categories',
    label: 'Categories',
    icon: Icons.category,
    category: 'Management',
    builder: (context, state) => const CategoryOverviewPage(),
  ),
  SproutRoute(
    path: '/rules',
    label: 'Rules',
    icon: Icons.receipt_long_rounded,
    category: 'Management',
    builder: (context, state) => const TransactionRulesPage(),
  ),
  SproutRoute(
    path: '/subscriptions',
    label: 'Subscriptions',
    icon: Icons.subscriptions,
    category: 'Banking',
    builder: (context, state) => const SubscriptionsPage(),
  ),
  SproutRoute(
    path: '/reports',
    label: 'Reports',
    icon: Icons.bar_chart,
    bottomNavPriority: 4,
    builder: (context, state) => const ReportsPage(),
  ),
  SproutRoute(
    path: '/settings',
    label: 'Settings',
    icon: Icons.settings_rounded,
    showInSidebar: false,
    builder: (context, state) => const SettingsPage(),
  ),
];

/// Returns the [authenticatedRoutes] but filtered considering the options
/// [restrictToSidebar] If we should filter out routes that are only allowed in the sidebar.
List<SproutRoute> getFilteredRoutes(
    UnsecureAppConfiguration unsecureConfig, APIConfig? apiConfig, UserConfig? userConfig,
    {List<SproutRoute>? routes, bool restrictToSidebar = true}) {
  return (routes ?? authenticatedRoutes).where((page) {
    if (restrictToSidebar && !page.showInSidebar) return false;
    if (apiConfig == null) return false;
    return page.enabled?.call(apiConfig, unsecureConfig, userConfig) ?? true;
  }).toList();
}

/// Helper function to check if a path exists within a route tree
bool isPathInRoutes(String path, List<SproutRoute> routes, {String currentPrefix = ''}) {
  for (final route in routes) {
    final fullRoutePath =
        route.path.startsWith('/') ? route.path : '${currentPrefix == '/' ? '' : currentPrefix}/${route.path}';
    if (path == fullRoutePath) return true;
    if (route.routes != null) {
      if (isPathInRoutes(path, route.routes!, currentPrefix: fullRoutePath)) {
        return true;
      }
    }
  }
  return false;
}
