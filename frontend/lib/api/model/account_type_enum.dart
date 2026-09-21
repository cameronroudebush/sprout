//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// The type of this account to better separate it from the others.
enum AccountTypeEnum {
  other._(r'other'),
  depository._(r'depository'),
  credit._(r'credit'),
  asset._(r'asset'),
  loan._(r'loan'),
  investment._(r'investment'),
  crypto._(r'crypto'),
  ;

  /// Instantiate a new enum with the provided value.
  const AccountTypeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [AccountTypeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static AccountTypeEnum? fromJson(dynamic value) => AccountTypeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [AccountTypeEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<AccountTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AccountTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AccountTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AccountTypeEnum] to String,
/// and [decode] dynamic data back to [AccountTypeEnum].
class AccountTypeEnumTypeTransformer {
  factory AccountTypeEnumTypeTransformer() => _instance ??= const AccountTypeEnumTypeTransformer._();

  const AccountTypeEnumTypeTransformer._();

  /// Encodes this enum as a value suitable for JSON.
  String encode(AccountTypeEnum data) => data._value;

  /// Returns the instance of [AccountTypeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AccountTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is AccountTypeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'other': return AccountTypeEnum.other;
        case r'depository': return AccountTypeEnum.depository;
        case r'credit': return AccountTypeEnum.credit;
        case r'asset': return AccountTypeEnum.asset;
        case r'loan': return AccountTypeEnum.loan;
        case r'investment': return AccountTypeEnum.investment;
        case r'crypto': return AccountTypeEnum.crypto;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static AccountTypeEnumTypeTransformer? _instance;
}

