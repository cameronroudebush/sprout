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
enum AccountSubTypeEnum {
  other._(r'other'),
  savings._(r'Savings'),
  checking._(r'Checking'),
  HYSA._(r'HYSA'),
  n401k._(r'401K'),
  brokerage._(r'Brokerage'),
  IRA._(r'IRA'),
  HSA._(r'HSA'),
  student._(r'Student'),
  mortgage._(r'Mortgage'),
  personal._(r'Personal'),
  auto._(r'Auto'),
  travel._(r'Travel'),
  cashBack._(r'Cash Back'),
  wallet._(r'Wallet'),
  staking._(r'Staking'),
  house._(r'House'),
  ;

  /// Instantiate a new enum with the provided value.
  const AccountSubTypeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [AccountSubTypeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static AccountSubTypeEnum? fromJson(dynamic value) => AccountSubTypeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [AccountSubTypeEnum]
  /// that were successfully decoded from the passed [JSON][json].
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

  /// Encodes this enum as a value suitable for JSON.
  String encode(AccountSubTypeEnum data) => data._value;

  /// Returns the instance of [AccountSubTypeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AccountSubTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is AccountSubTypeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'other': return AccountSubTypeEnum.other;
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
        case r'House': return AccountSubTypeEnum.house;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static AccountSubTypeEnumTypeTransformer? _instance;
}

