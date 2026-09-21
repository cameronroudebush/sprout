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
class AccountTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const AccountTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const other = AccountTypeEnum._(r'other');
  static const depository = AccountTypeEnum._(r'depository');
  static const credit = AccountTypeEnum._(r'credit');
  static const asset = AccountTypeEnum._(r'asset');
  static const loan = AccountTypeEnum._(r'loan');
  static const investment = AccountTypeEnum._(r'investment');
  static const crypto = AccountTypeEnum._(r'crypto');

  /// List of all possible values in this [enum][AccountTypeEnum].
  static const values = <AccountTypeEnum>[
    other,
    depository,
    credit,
    asset,
    loan,
    investment,
    crypto,
  ];

  static AccountTypeEnum? fromJson(dynamic value) => AccountTypeEnumTypeTransformer().decode(value);

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

  String encode(AccountTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AccountTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AccountTypeEnum? decode(dynamic data, {bool allowNull = true}) {
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

  /// Singleton [AccountTypeEnumTypeTransformer] instance.
  static AccountTypeEnumTypeTransformer? _instance;
}

