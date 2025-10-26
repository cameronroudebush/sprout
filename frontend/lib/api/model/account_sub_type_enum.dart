//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// The subtype of this account. For example, a depository could be a checking account, savings account, or HYSA.
class AccountSubTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const AccountSubTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const savings = AccountSubTypeEnum._(r'Savings');
  static const checking = AccountSubTypeEnum._(r'Checking');
  static const HYSA = AccountSubTypeEnum._(r'HYSA');
  static const n401k = AccountSubTypeEnum._(r'401K');
  static const brokerage = AccountSubTypeEnum._(r'Brokerage');
  static const IRA = AccountSubTypeEnum._(r'IRA');
  static const HSA = AccountSubTypeEnum._(r'HSA');
  static const student = AccountSubTypeEnum._(r'Student');
  static const mortgage = AccountSubTypeEnum._(r'Mortgage');
  static const personal = AccountSubTypeEnum._(r'Personal');
  static const auto = AccountSubTypeEnum._(r'Auto');
  static const travel = AccountSubTypeEnum._(r'Travel');
  static const cashBack = AccountSubTypeEnum._(r'Cash Back');
  static const wallet = AccountSubTypeEnum._(r'Wallet');
  static const staking = AccountSubTypeEnum._(r'Staking');

  /// List of all possible values in this [enum][AccountSubTypeEnum].
  static const values = <AccountSubTypeEnum>[
    savings,
    checking,
    HYSA,
    n401k,
    brokerage,
    IRA,
    HSA,
    student,
    mortgage,
    personal,
    auto,
    travel,
    cashBack,
    wallet,
    staking,
  ];

  static AccountSubTypeEnum? fromJson(dynamic value) => AccountSubTypeEnumTypeTransformer().decode(value);

  static List<AccountSubTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AccountSubTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AccountSubTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AccountSubTypeEnum] to String,
/// and [decode] dynamic data back to [AccountSubTypeEnum].
class AccountSubTypeEnumTypeTransformer {
  factory AccountSubTypeEnumTypeTransformer() => _instance ??= const AccountSubTypeEnumTypeTransformer._();

  const AccountSubTypeEnumTypeTransformer._();

  String encode(AccountSubTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AccountSubTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AccountSubTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'Savings': return AccountSubTypeEnum.savings;
        case r'Checking': return AccountSubTypeEnum.checking;
        case r'HYSA': return AccountSubTypeEnum.HYSA;
        case r'401K': return AccountSubTypeEnum.n401k;
        case r'Brokerage': return AccountSubTypeEnum.brokerage;
        case r'IRA': return AccountSubTypeEnum.IRA;
        case r'HSA': return AccountSubTypeEnum.HSA;
        case r'Student': return AccountSubTypeEnum.student;
        case r'Mortgage': return AccountSubTypeEnum.mortgage;
        case r'Personal': return AccountSubTypeEnum.personal;
        case r'Auto': return AccountSubTypeEnum.auto;
        case r'Travel': return AccountSubTypeEnum.travel;
        case r'Cash Back': return AccountSubTypeEnum.cashBack;
        case r'Wallet': return AccountSubTypeEnum.wallet;
        case r'Staking': return AccountSubTypeEnum.staking;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AccountSubTypeEnumTypeTransformer] instance.
  static AccountSubTypeEnumTypeTransformer? _instance;
}

