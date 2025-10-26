//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TransactionRule {
  /// Returns a new [TransactionRule] instance.
  TransactionRule({
    required this.id,
    required this.type,
    required this.value,
    this.category,
    required this.strict,
    this.matches = 0,
    this.order = 0,
    this.enabled = true,
  });

  String id;

  TransactionRuleTypeEnum type;

  /// This defines the value of the rule. Strings support | to split content
  String value;

  /// This defines the category to set the transaction to
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Category? category;

  /// If this match should be strict. So if it should be the exact string or the exact number.
  bool strict;

  /// How many transactions have been updated by this transaction rule.
  num matches;

  /// The order of priority of this value
  num order;

  /// If this rule should be executed
  bool enabled;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TransactionRule &&
    other.id == id &&
    other.type == type &&
    other.value == value &&
    other.category == category &&
    other.strict == strict &&
    other.matches == matches &&
    other.order == order &&
    other.enabled == enabled;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (type.hashCode) +
    (value.hashCode) +
    (category == null ? 0 : category!.hashCode) +
    (strict.hashCode) +
    (matches.hashCode) +
    (order.hashCode) +
    (enabled.hashCode);

  @override
  String toString() => 'TransactionRule[id=$id, type=$type, value=$value, category=$category, strict=$strict, matches=$matches, order=$order, enabled=$enabled]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'type'] = this.type;
      json[r'value'] = this.value;
    if (this.category != null) {
      json[r'category'] = this.category;
    } else {
      json[r'category'] = null;
    }
      json[r'strict'] = this.strict;
      json[r'matches'] = this.matches;
      json[r'order'] = this.order;
      json[r'enabled'] = this.enabled;
    return json;
  }

  /// Returns a new [TransactionRule] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TransactionRule? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TransactionRule[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TransactionRule[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return TransactionRule(
        id: mapValueOfType<String>(json, r'id')!,
        type: TransactionRuleTypeEnum.fromJson(json[r'type'])!,
        value: mapValueOfType<String>(json, r'value')!,
        category: Category.fromJson(json[r'category']),
        strict: mapValueOfType<bool>(json, r'strict')!,
        matches: num.parse('${json[r'matches']}'),
        order: num.parse('${json[r'order']}'),
        enabled: mapValueOfType<bool>(json, r'enabled')!,
      );
    }
    return null;
  }

  static List<TransactionRule> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TransactionRule>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TransactionRule.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TransactionRule> mapFromJson(dynamic json) {
    final map = <String, TransactionRule>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TransactionRule.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TransactionRule-objects as value to a dart map
  static Map<String, List<TransactionRule>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TransactionRule>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TransactionRule.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'type',
    'value',
    'strict',
    'matches',
    'order',
    'enabled',
  };
}


class TransactionRuleTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const TransactionRuleTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const description = TransactionRuleTypeEnum._(r'description');
  static const amount = TransactionRuleTypeEnum._(r'amount');

  /// List of all possible values in this [enum][TransactionRuleTypeEnum].
  static const values = <TransactionRuleTypeEnum>[
    description,
    amount,
  ];

  static TransactionRuleTypeEnum? fromJson(dynamic value) => TransactionRuleTypeEnumTypeTransformer().decode(value);

  static List<TransactionRuleTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TransactionRuleTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TransactionRuleTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [TransactionRuleTypeEnum] to String,
/// and [decode] dynamic data back to [TransactionRuleTypeEnum].
class TransactionRuleTypeEnumTypeTransformer {
  factory TransactionRuleTypeEnumTypeTransformer() => _instance ??= const TransactionRuleTypeEnumTypeTransformer._();

  const TransactionRuleTypeEnumTypeTransformer._();

  String encode(TransactionRuleTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a TransactionRuleTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  TransactionRuleTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'description': return TransactionRuleTypeEnum.description;
        case r'amount': return TransactionRuleTypeEnum.amount;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [TransactionRuleTypeEnumTypeTransformer] instance.
  static TransactionRuleTypeEnumTypeTransformer? _instance;
}


