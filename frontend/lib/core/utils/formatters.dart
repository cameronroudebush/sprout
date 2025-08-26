import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/user/provider.dart';

/// Converts the given number into a formatted currency. Currently only works with USD.
///
/// @round If we should round this value and drop the decimals
String getFormattedCurrency(dynamic value, {bool round = false}) {
  if (value == -0.0) value = 0.0;
  final userProvider = ServiceLocator.get<UserProvider>();
  final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: round ? 0 : null);
  if (round) value = value.round();
  return userProvider.currentUserConfig?.privateMode == true ? "***" : currencyFormatter.format(value);
}

String formatDate(DateTime date, {bool includeTime = false}) {
  final format = includeTime ? "MM/dd/yyyy HH:mm" : "MM/dd/yyyy";
  return DateFormat(format).format(date.toLocal());
}

/// Returns the given number as a percentage
String formatPercentage(double number) {
  if (number == -0.0) number = 0.0;
  return "${number.toStringAsFixed(2)}%";
}

extension StringCasingExtension on String {
  String get toCapitalized => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String get toTitleCase => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized).join(' ');
}

/// Returns the color to display for a balance
Color getBalanceColor(double balance, ThemeData theme) {
  final checkVal = num.parse(balance.toStringAsFixed(2));
  return checkVal < 0
      ? Colors.red
      : checkVal > 0
      ? Colors.green
      : theme.primaryTextTheme.bodyLarge!.color!;
}

/// Returns the icon for a change in net worth
IconData getChangeIcon(double percentChange) {
  final checkVal = num.parse(percentChange.toStringAsFixed(2));
  return checkVal == 0.0
      ? Icons.horizontal_rule
      : checkVal > 0
      ? Icons.arrow_upward
      : Icons.arrow_downward;
}

/// Formats the given account type string to a prettier name
String formatAccountType(String accountType) {
  switch (accountType) {
    case "depository":
      return "Cash";
    case "credit":
      return "Credit Card";
    default:
      return accountType.toTitleCase;
  }
}
