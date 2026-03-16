import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension SproutCurrencyFormatter on num {
  /// Converts the number into a formatted USD currency string.
  /// Respects [privateMode] by obscuring the value.
  String toCurrency(bool privateMode, {bool round = false}) {
    if (privateMode) return "***";

    // Fix for negative zero display issues
    double value = this == -0.0 ? 0.0 : toDouble();

    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: round ? 0 : null);

    return formatter.format(round ? value.round() : value);
  }

  /// Returns a shortened format (K, M, B) for large numbers.
  String toShortCurrency(bool privateMode) {
    if (privateMode) return "***";

    String returnVal;
    final number = abs();
    final sign = this < 0 ? "-" : "";

    if (number >= 1000000000) {
      returnVal = '${sign}\$${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      returnVal = '${sign}\$${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      returnVal = '${sign}\$${(number / 1000).toStringAsFixed(1)}K';
    } else {
      returnVal = '${sign}\$${number.toStringAsFixed(0)}';
    }
    return returnVal;
  }

  /// Returns the semantic color for a balance (Red for negative, Green for positive)
  Color toBalanceColor(ThemeData theme) {
    final checkVal = double.parse(toStringAsFixed(2));
    if (checkVal < 0) return Colors.red;
    if (checkVal > 0) return Colors.green;
    return theme.textTheme.bodyLarge?.color ?? Colors.grey;
  }

  /// Returns the appropriate icon for a change in value
  IconData toChangeIcon() {
    final checkVal = double.parse(toStringAsFixed(2));
    if (checkVal == 0.0 || checkVal.isNaN) return Icons.horizontal_rule;
    return checkVal > 0 ? Icons.arrow_upward : Icons.arrow_downward;
  }
}

extension SproutStringFormatter on String {
  /// Obscures currency patterns within a string
  String deIdentifyCurrency() {
    final currencyRegex = RegExp(r'([$€£¥])\s?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?|\d+(?:\.\d{2})?)');
    return replaceAllMapped(currencyRegex, (match) {
      final symbol = match.group(1);
      return '$symbol••••';
    });
  }
}
