import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/user/provider.dart';

final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

/// Converts the given number into a formatted currency. Currently only works with USD.
String getFormattedCurrency(double value) {
  final userProvider = ServiceLocator.get<UserProvider>();
  return userProvider.currentUserConfig?.privateMode == true ? "***" : _currencyFormatter.format(value);
}

String formatDate(DateTime date) {
  return DateFormat('MM/dd/yyyy').format(date.toLocal());
}

/// Returns the given number as a percentage
String formatPercentage(double number) {
  return "${number.toStringAsFixed(2)}%";
}

extension StringCasingExtension on String {
  String get toCapitalized => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String get toTitleCase => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized).join(' ');
}

/// Returns the color to display for a balance
Color getBalanceColor(double balance, ThemeData theme) {
  return balance < 0
      ? Colors.red
      : balance > 0
      ? Colors.green
      : theme.primaryTextTheme.bodyLarge!.color!;
}

/// Returns the icon for a change in net worth
IconData getChangeIcon(double percentChange) {
  return percentChange == 0.0
      ? Icons.horizontal_rule
      : percentChange > 0
      ? Icons.arrow_upward
      : Icons.arrow_downward;
}
