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

/// Returns the formatted currency but in a short format
String getShortFormattedCurrency(dynamic number) {
  final userProvider = ServiceLocator.get<UserProvider>();
  String returnVal;
  if (number >= 1000000000) {
    returnVal = '\$${(number / 1000000000).toStringAsFixed(1)}B';
  } else if (number >= 1000000) {
    returnVal = '\$${(number / 1000000).toStringAsFixed(1)}M';
  } else if (number >= 1000) {
    returnVal = '\$${(number / 1000).toStringAsFixed(1)}K';
  } else {
    returnVal = '\$${number.toStringAsFixed(0)}';
  }
  return userProvider.currentUserConfig?.privateMode == true ? "***" : returnVal;
}

/// Returns the given number as a percentage
String formatPercentage(double number) {
  if (number == -0.0) number = 0.0;
  return "${number.toStringAsFixed(2)}%";
}

/// String formatters
extension StringCasingExtension on String {
  String get toCapitalized => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String get toTitleCase => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized).join(' ');
  String get snakeCase {
    String snakeCase = replaceAll(
      RegExp(r'\s'),
      '',
    ).replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}');
    if (snakeCase.startsWith('_')) snakeCase = snakeCase.substring(1);
    return snakeCase;
  }

  String get kebabCase {
    String k = replaceAll(
      RegExp(r'\s'),
      '',
    ).replaceAllMapped(RegExp(r'[A-Z]'), (match) => '-${match.group(0)!.toLowerCase()}');
    if (k.startsWith('-')) k = k.substring(1);
    return k;
  }
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
  return checkVal == 0.0 || checkVal.isNaN
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

/// Returns a locale formatted number
String formatNumber(dynamic number) {
  return NumberFormat().format(number);
}

/// Date formatters
extension DateToStringFormatterExtension on DateTime {
  /// MM/dd/yyyy
  String get toShort => DateFormat("MM/dd/yyyy").format(toLocal());

  /// MM/dd/yyyy
  String get toShortMonth => DateFormat("MMM dd, yyyy").format(toLocal());

  /// Returns true if the given date is on the same day as this date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
