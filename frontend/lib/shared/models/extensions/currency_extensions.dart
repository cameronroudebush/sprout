import 'package:flutter/material.dart';

extension SproutCurrencyFormatter on num {
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
    final currencyRegex = RegExp(r'([$€£¥¤])\s?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?|\d+(?:\.\d{2})?)');
    return replaceAllMapped(currencyRegex, (match) {
      final symbol = match.group(1);
      return '$symbol••••';
    });
  }
}
