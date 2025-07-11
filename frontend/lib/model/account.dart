import 'package:flutter/material.dart';

/// This account defines what an account should look like from the API
class Account {
  final String name;
  final String provider;
  final String currency;
  final String type;

  final double balance;
  final double availableBalance;

  final IconData icon;

  Account({
    required this.name,
    required this.balance,
    required this.icon,
    required this.provider,
    required this.availableBalance,
    required this.currency,
    required this.type,
  });

  /// Convert the
  factory Account.fromJson(Map<String, dynamic> json) {
    IconData defaultIcon = Icons.account_balance;
    if (json['type'] == 'depository') {
      defaultIcon = Icons.account_balance;
    } else if (json['type'] == 'loan') {
      defaultIcon = Icons.savings;
    } else if (json['type'] == 'credit') {
      defaultIcon = Icons.credit_card;
    } else if (json['type'] == 'investment') {
      defaultIcon = Icons.trending_up;
    }

    return Account(
      name: json['name'] as String,
      provider: json['provider'] as String,
      currency: json['currency'] as String,
      type: json['type'] as String,
      balance: (json['balance'] as num).toDouble(),
      availableBalance: (json['availableBalance'] as num).toDouble(),
      icon: defaultIcon,
    );
  }
}
