import 'package:flutter/material.dart';
import 'package:sprout/model/institution.dart';

/// This account defines what an account should look like from the API
class Account {
  final String name;
  final String provider;
  final String currency;
  final String type;

  final double balance;
  final double availableBalance;

  final Institution institution;

  final IconData icon;

  Account({
    required this.name,
    required this.balance,
    required this.icon,
    required this.provider,
    required this.availableBalance,
    required this.currency,
    required this.type,
    required this.institution,
  });

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
      institution: Institution.fromJson(json["institution"]),
    );
  }

  /// Converts this object to JSON object
  dynamic toJson() {
    return {
      'name': name,
      'provider': provider,
      'currency': currency,
      'type': type,
      'balance': balance,
      'availableBalance': availableBalance,
    };
  }
}
