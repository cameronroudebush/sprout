import 'package:sprout/transaction/models/category.dart';

/// An enum to represent the fixed types of a transaction rule.
enum TransactionRuleType {
  description,
  amount;

  /// Converts a string to its corresponding enum value.
  static TransactionRuleType fromString(String type) {
    if (type == 'description') {
      return TransactionRuleType.description;
    }
    if (type == 'amount') {
      return TransactionRuleType.amount;
    }
    throw Exception('Invalid TransactionRuleType string: $type');
  }
}

/// A class representing a transaction rule.
class TransactionRule {
  final String id;
  final TransactionRuleType type;
  final String value;
  final Category? category;
  final bool strict;
  final int order;
  final bool enabled;
  final int matches;

  const TransactionRule({
    required this.id,
    required this.type,
    required this.value,
    required this.category,
    required this.strict,
    required this.order,
    required this.enabled,
    required this.matches,
  });

  /// A factory constructor to create a TransactionRule instance from a JSON map.
  factory TransactionRule.fromJson(Map<String, dynamic> json) {
    return TransactionRule(
      id: json['id'] as String,
      type: TransactionRuleType.fromString(json['type'] as String),
      value: json['value'] as String,
      category: json['category'] == null ? null : Category.fromJson(json['category']),
      strict: json['strict'] as bool,
      order: json['order'] as int,
      enabled: json['enabled'] as bool,
      matches: json['matches'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'value': value,
      'category': category?.toJson(),
      'strict': strict,
      'order': order,
      'enabled': enabled,
      'matches': matches,
    };
  }

  TransactionRule copyWith({
    String? id,
    TransactionRuleType? type,
    String? value,
    Category? category,
    bool? strict,
    int? order,
    bool? enabled,
    int? matches,
  }) {
    return TransactionRule(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      category: category ?? this.category,
      strict: strict ?? this.strict,
      order: order ?? this.order,
      enabled: enabled ?? this.enabled,
      matches: matches ?? this.matches,
    );
  }
}
