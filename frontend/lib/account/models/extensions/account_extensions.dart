import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';

/// Helper functions for account
extension AccountExtensions on Account {
  /// Centralized configuration for account UI
  static const Map<AccountTypeEnum, ({String title, Color color, bool isNegative})> groupConfig = {
    AccountTypeEnum.depository: (title: "Cash", color: Colors.teal, isNegative: false),
    AccountTypeEnum.investment: (title: "Investments", color: Colors.green, isNegative: false),
    AccountTypeEnum.crypto: (title: "Crypto", color: Colors.blue, isNegative: false),
    AccountTypeEnum.credit: (title: "Credit Cards", color: Colors.red, isNegative: true),
    AccountTypeEnum.loan: (title: "Loans", color: Colors.orangeAccent, isNegative: true),
  };
}
