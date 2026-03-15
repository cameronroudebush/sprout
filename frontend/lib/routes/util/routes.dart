import 'package:flutter/material.dart';
import 'package:sprout/routes/accounts.dart';
import 'package:sprout/routes/categories.dart';
import 'package:sprout/routes/chat.dart';
import 'package:sprout/routes/dashboard.dart';
import 'package:sprout/routes/transaction_rules.dart';
import 'package:sprout/routes/transactions.dart';
import 'package:sprout/routes/user_config.dart';
import 'package:sprout/routes/util/route.dart';

/// List of routes that require authentication
final List<SproutRoute> authenticatedRoutes = [
  SproutRoute(
    path: '/chat',
    label: 'Chat',
    icon: Icons.auto_awesome,
    showInBottomNav: true,
    builder: (context, state) => const ChatPage(),
  ),
  SproutRoute(
    path: '/accounts',
    label: 'Accounts',
    icon: Icons.account_balance,
    builder: (context, state) => const AccountsPage(),
  ),
  SproutRoute(
    path: '/',
    label: 'Dashboard',
    icon: Icons.dashboard_rounded,
    showInBottomNav: true,
    builder: (context, state) => const DashboardPage(),
  ),
  SproutRoute(
    path: '/transactions',
    label: 'Transactions',
    icon: Icons.receipt,
    showInBottomNav: true,
    builder: (context, state) => const TransactionsPage(),
  ),
  SproutRoute(
    path: '/categories',
    label: 'Categories',
    icon: Icons.category,
    builder: (context, state) => const CategoryOverviewPage(),
  ),
  SproutRoute(
    path: '/rules',
    label: 'Rules',
    icon: Icons.receipt_long_rounded,
    builder: (context, state) => const TransactionRulesPage(),
  ),
  SproutRoute(
    path: '/subscriptions',
    label: 'Subscriptions',
    icon: Icons.subscriptions,
    builder: (context, state) => const Placeholder(),
  ),
  SproutRoute(
    path: '/reports',
    label: 'Reports',
    icon: Icons.bar_chart,
    showInBottomNav: true,
    builder: (context, state) => const Placeholder(),
  ),
  SproutRoute(
    path: '/settings',
    label: 'Settings',
    icon: Icons.settings_rounded,
    showInSidebar: false,
    builder: (context, state) => const UserConfigPage(),
  ),
];
