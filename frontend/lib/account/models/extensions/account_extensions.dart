import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';

/// Helper functions for account
extension AccountExtensions on Account {
  /// Centralized configuration for account UI
  static const Map<AccountTypeEnum, ({String title, Color color, bool isNegative})> groupConfig = {
    AccountTypeEnum.depository: (title: "Cash", color: Color(0xFF00796B), isNegative: false),
    AccountTypeEnum.investment: (title: "Investment", color: Color(0xFF1B5E20), isNegative: false),
    AccountTypeEnum.asset: (title: "Asset", color: Color(0xFF6A1B9A), isNegative: false),
    AccountTypeEnum.crypto: (title: "Crypto", color: Color(0xFF0D47A1), isNegative: false),
    AccountTypeEnum.credit: (title: "Credit Card", color: Color(0xFFB71C1C), isNegative: true),
    AccountTypeEnum.loan: (title: "Loan", color: Color(0xFFE65100), isNegative: true),
    AccountTypeEnum.other: (title: "Other", color: Color(0xFF00695C), isNegative: false),
  };

  /// Returns true if the account type represents a debt (Credit or Loan).
  bool get isDebt {
    return type == AccountTypeEnum.credit || type == AccountTypeEnum.loan;
  }

  bool get isAsset {
    return !isDebt;
  }
}
