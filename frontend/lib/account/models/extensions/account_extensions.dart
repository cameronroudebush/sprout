import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';

/// Helper functions for account
extension AccountExtensions on Account {
  /// Centralized configuration for account UI
  static const Map<AccountTypeEnum, ({String title, Color color, bool isNegative})> groupConfig = {
    AccountTypeEnum.depository: (title: "Cash", color: Colors.teal, isNegative: false),
    AccountTypeEnum.investment: (title: "Investment", color: Colors.green, isNegative: false),
    AccountTypeEnum.asset: (title: "Asset", color: Colors.purple, isNegative: false),
    AccountTypeEnum.crypto: (title: "Crypto", color: Colors.blue, isNegative: false),
    AccountTypeEnum.credit: (title: "Credit Card", color: Colors.red, isNegative: true),
    AccountTypeEnum.loan: (title: "Loan", color: Colors.orangeAccent, isNegative: true),
  };

  /// Returns true if the account type represents a debt (Credit or Loan).
  bool get isDebt {
    return type == AccountTypeEnum.credit || type == AccountTypeEnum.loan;
  }

  /// Optional: Returns true if the account is an asset (Depository, Investment, etc.)
  bool get isAsset {
    return !isDebt;
  }
}
