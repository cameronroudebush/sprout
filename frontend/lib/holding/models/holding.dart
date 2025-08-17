import 'package:sprout/account/models/account.dart';

/// This class provides information for a current stock that is associated to an account.
class Holding {
  /// The account this holding is associated to
  final Account account;

  final String currency;

  final double costBasis;

  /// A description of what this holding is
  final String description;

  /// The current market value
  final double marketValue;

  /// The current purchase price
  final double purchasePrice;

  /// Total number of shares, including fractional
  final double shares;

  /// The symbol for this holding
  final String symbol;

  Holding({
    required this.currency,
    required this.costBasis,
    required this.description,
    required this.marketValue,
    required this.purchasePrice,
    required this.shares,
    required this.symbol,
    required this.account,
  });

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      currency: json['currency'],
      costBasis: json['costBasis']?.toDouble(),
      description: json['description'],
      marketValue: json['marketValue']?.toDouble(),
      purchasePrice: json['purchasePrice']?.toDouble(),
      shares: json['shares']?.toDouble(),
      symbol: json['symbol'],
      account: Account.fromJson(json['account']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'costBasis': costBasis,
      'description': description,
      'marketValue': marketValue,
      'purchasePrice': purchasePrice,
      'shares': shares,
      'symbol': symbol,
      'account': account.toJson(),
    };
  }
}
