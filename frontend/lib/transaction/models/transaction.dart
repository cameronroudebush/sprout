import 'package:sprout/account/models/account.dart';
import 'package:sprout/transaction/models/category.dart';

class Transaction {
  final String id;

  /// In the currency of the account
  final double amount;
  final String description;
  final bool pending;
  final Category? category;

  /// The date this transaction posted
  final DateTime posted;

  /// The account this transaction belongs to
  final Account account;

  Transaction({
    required this.id,
    required this.amount,
    required this.posted,
    required this.description,
    required this.category,
    required this.pending,
    required this.account,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      pending: json['pending'] as bool,
      category: json['category'] == null ? null : Category.fromJson(json['category']),
      posted: DateTime.parse(json['posted'] as String),
      account: Account.fromJson(json['account'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'pending': pending,
      'category': category?.toJson(),
      'posted': posted.toIso8601String(),
      'account': account.toJson(),
    };
  }
}
