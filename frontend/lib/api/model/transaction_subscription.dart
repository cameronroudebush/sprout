//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TransactionSubscription {
  /// Returns a new [TransactionSubscription] instance.
  TransactionSubscription({
    required this.account,
    required this.transaction,
    required this.description,
    required this.amount,
    required this.count,
    required this.period,
    required this.startDate,
  });

  /// The account related to this subscription
  Account account;

  /// The transaction that matches the first subscription indication
  Transaction transaction;

  /// The description of this transaction
  String description;

  /// The amount of this transaction
  num amount;

  /// The number of these transactions we have counted
  num count;

  /// How often this is billed
  TransactionSubscriptionPeriodEnum period;

  /// The day this billing starts
  DateTime startDate;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TransactionSubscription &&
    other.account == account &&
    other.transaction == transaction &&
    other.description == description &&
    other.amount == amount &&
    other.count == count &&
    other.period == period &&
    other.startDate == startDate;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (account.hashCode) +
    (transaction.hashCode) +
    (description.hashCode) +
    (amount.hashCode) +
    (count.hashCode) +
    (period.hashCode) +
    (startDate.hashCode);

  @override
  String toString() => 'TransactionSubscription[account=$account, transaction=$transaction, description=$description, amount=$amount, count=$count, period=$period, startDate=$startDate]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'account'] = this.account;
      json[r'transaction'] = this.transaction;
      json[r'description'] = this.description;
      json[r'amount'] = this.amount;
      json[r'count'] = this.count;
      json[r'period'] = this.period;
      json[r'startDate'] = this.startDate.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [TransactionSubscription] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TransactionSubscription? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TransactionSubscription[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TransactionSubscription[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return TransactionSubscription(
        account: Account.fromJson(json[r'account'])!,
        transaction: Transaction.fromJson(json[r'transaction'])!,
        description: mapValueOfType<String>(json, r'description')!,
        amount: num.parse('${json[r'amount']}'),
        count: num.parse('${json[r'count']}'),
        period: TransactionSubscriptionPeriodEnum.fromJson(json[r'period'])!,
        startDate: mapDateTime(json, r'startDate', r'')!,
      );
    }
    return null;
  }

  static List<TransactionSubscription> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TransactionSubscription>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TransactionSubscription.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TransactionSubscription> mapFromJson(dynamic json) {
    final map = <String, TransactionSubscription>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TransactionSubscription.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TransactionSubscription-objects as value to a dart map
  static Map<String, List<TransactionSubscription>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TransactionSubscription>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TransactionSubscription.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'account',
    'transaction',
    'description',
    'amount',
    'count',
    'period',
    'startDate',
  };
}

/// How often this is billed
class TransactionSubscriptionPeriodEnum {
  /// Instantiate a new enum with the provided [value].
  const TransactionSubscriptionPeriodEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const weekly = TransactionSubscriptionPeriodEnum._(r'weekly');
  static const biWeekly = TransactionSubscriptionPeriodEnum._(r'bi-weekly');
  static const monthly = TransactionSubscriptionPeriodEnum._(r'monthly');
  static const quarterly = TransactionSubscriptionPeriodEnum._(r'quarterly');
  static const semiAnnually = TransactionSubscriptionPeriodEnum._(r'semi-annually');
  static const yearly = TransactionSubscriptionPeriodEnum._(r'yearly');
  static const unknown = TransactionSubscriptionPeriodEnum._(r'unknown');

  /// List of all possible values in this [enum][TransactionSubscriptionPeriodEnum].
  static const values = <TransactionSubscriptionPeriodEnum>[
    weekly,
    biWeekly,
    monthly,
    quarterly,
    semiAnnually,
    yearly,
    unknown,
  ];

  static TransactionSubscriptionPeriodEnum? fromJson(dynamic value) => TransactionSubscriptionPeriodEnumTypeTransformer().decode(value);

  static List<TransactionSubscriptionPeriodEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TransactionSubscriptionPeriodEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TransactionSubscriptionPeriodEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [TransactionSubscriptionPeriodEnum] to String,
/// and [decode] dynamic data back to [TransactionSubscriptionPeriodEnum].
class TransactionSubscriptionPeriodEnumTypeTransformer {
  factory TransactionSubscriptionPeriodEnumTypeTransformer() => _instance ??= const TransactionSubscriptionPeriodEnumTypeTransformer._();

  const TransactionSubscriptionPeriodEnumTypeTransformer._();

  String encode(TransactionSubscriptionPeriodEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a TransactionSubscriptionPeriodEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  TransactionSubscriptionPeriodEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'weekly': return TransactionSubscriptionPeriodEnum.weekly;
        case r'bi-weekly': return TransactionSubscriptionPeriodEnum.biWeekly;
        case r'monthly': return TransactionSubscriptionPeriodEnum.monthly;
        case r'quarterly': return TransactionSubscriptionPeriodEnum.quarterly;
        case r'semi-annually': return TransactionSubscriptionPeriodEnum.semiAnnually;
        case r'yearly': return TransactionSubscriptionPeriodEnum.yearly;
        case r'unknown': return TransactionSubscriptionPeriodEnum.unknown;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [TransactionSubscriptionPeriodEnumTypeTransformer] instance.
  static TransactionSubscriptionPeriodEnumTypeTransformer? _instance;
}


