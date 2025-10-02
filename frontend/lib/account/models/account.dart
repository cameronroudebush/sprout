import 'package:flutter/material.dart';
import 'package:sprout/account/models/institution.dart';

enum DepositoryAccountType {
  savings('Savings'),
  checking('Checking'),
  hysa('HYSA');

  const DepositoryAccountType(this.value);
  final String value;
}

enum InvestmentAccountType {
  four01k('401K'),
  brokerage('Brokerage'),
  ira('IRA'),
  hsa('HSA');

  const InvestmentAccountType(this.value);
  final String value;
}

enum LoanAccountType {
  student('Student'),
  mortgage('Mortgage'),
  personal('Personal'),
  auto('Auto');

  const LoanAccountType(this.value);
  final String value;
}

enum CreditAccountType {
  travel('Travel'),
  cashBack('Cash Back');

  const CreditAccountType(this.value);
  final String value;
}

/// This account defines what an account should look like from the API
class Account {
  final String id;
  final String name;
  final String provider;
  final String currency;
  final String type;

  final double balance;
  final double availableBalance;

  final Institution institution;

  /// An icon to use in the event the institution url's logo can't be found
  final IconData fallbackIcon;

  /// The subtype of this account. For example, a depository could be a checking account, savings account, or HYSA.
  String? subType;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.fallbackIcon,
    required this.provider,
    required this.availableBalance,
    required this.currency,
    required this.type,
    this.subType,
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
      id: json['id'] as String,
      name: json['name'] as String,
      provider: json['provider'] as String,
      currency: json['currency'] as String,
      type: json['type'] as String,
      balance: (json['balance'] as num).toDouble(),
      availableBalance: (json['availableBalance'] as num).toDouble(),
      subType: json['subType'],
      fallbackIcon: defaultIcon,
      institution: Institution.fromJson(json["institution"]),
    );
  }

  /// Converts this object to JSON object
  dynamic toJson() {
    return {
      'id': id,
      'name': name,
      'provider': provider,
      'currency': currency,
      'type': type,
      'balance': balance,
      'availableBalance': availableBalance,
      'subType': subType,
    };
  }

  /// Returns if this account affects the net worth negativity due to being a loan type.
  get isNegativeNetWorth {
    return type == "credit" || type == "loan";
  }
}
