//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Account {
  /// Returns a new [Account] instance.
  Account({
    required this.id,
    required this.provider,
    this.subType,
    this.interestRate,
    required this.name,
    required this.institution,
    required this.currency,
    required this.balance,
    required this.availableBalance,
    required this.type,
    this.extra,
  });

  String id;

  ProviderTypeEnum provider;

  /// The subtype of this account. For example, a depository could be a checking account, savings account, or HYSA.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  AccountSubTypeEnum? subType;

  /// An interest rate if this is a loan type account.
  num? interestRate;

  String name;

  /// The institution associated to this account
  Institution institution;

  /// The currency this account uses
  String currency;

  /// The current balance of the account
  num balance;

  /// The available balance to this account
  num availableBalance;

  /// The type of this account to better separate it from the others.
  AccountTypeEnum type;

  /// Any extra data that we want to store as JSON
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Object? extra;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Account &&
    other.id == id &&
    other.provider == provider &&
    other.subType == subType &&
    other.interestRate == interestRate &&
    other.name == name &&
    other.institution == institution &&
    other.currency == currency &&
    other.balance == balance &&
    other.availableBalance == availableBalance &&
    other.type == type &&
    other.extra == extra;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (provider.hashCode) +
    (subType == null ? 0 : subType!.hashCode) +
    (interestRate == null ? 0 : interestRate!.hashCode) +
    (name.hashCode) +
    (institution.hashCode) +
    (currency.hashCode) +
    (balance.hashCode) +
    (availableBalance.hashCode) +
    (type.hashCode) +
    (extra == null ? 0 : extra!.hashCode);

  @override
  String toString() => 'Account[id=$id, provider=$provider, subType=$subType, interestRate=$interestRate, name=$name, institution=$institution, currency=$currency, balance=$balance, availableBalance=$availableBalance, type=$type, extra=$extra]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'provider'] = this.provider;
    if (this.subType != null) {
      json[r'subType'] = this.subType;
    } else {
      json[r'subType'] = null;
    }
    if (this.interestRate != null) {
      json[r'interestRate'] = this.interestRate;
    } else {
      json[r'interestRate'] = null;
    }
      json[r'name'] = this.name;
      json[r'institution'] = this.institution;
      json[r'currency'] = this.currency;
      json[r'balance'] = this.balance;
      json[r'availableBalance'] = this.availableBalance;
      json[r'type'] = this.type;
    if (this.extra != null) {
      json[r'extra'] = this.extra;
    } else {
      json[r'extra'] = null;
    }
    return json;
  }

  /// Returns a new [Account] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Account? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Account[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Account[id]" has a null value in JSON.');
        assert(json.containsKey(r'provider'), 'Required key "Account[provider]" is missing from JSON.');
        assert(json[r'provider'] != null, 'Required key "Account[provider]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "Account[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "Account[name]" has a null value in JSON.');
        assert(json.containsKey(r'institution'), 'Required key "Account[institution]" is missing from JSON.');
        assert(json[r'institution'] != null, 'Required key "Account[institution]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "Account[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "Account[currency]" has a null value in JSON.');
        assert(json.containsKey(r'balance'), 'Required key "Account[balance]" is missing from JSON.');
        assert(json[r'balance'] != null, 'Required key "Account[balance]" has a null value in JSON.');
        assert(json.containsKey(r'availableBalance'), 'Required key "Account[availableBalance]" is missing from JSON.');
        assert(json[r'availableBalance'] != null, 'Required key "Account[availableBalance]" has a null value in JSON.');
        assert(json.containsKey(r'type'), 'Required key "Account[type]" is missing from JSON.');
        assert(json[r'type'] != null, 'Required key "Account[type]" has a null value in JSON.');
        return true;
      }());

      return Account(
        id: mapValueOfType<String>(json, r'id')!,
        provider: ProviderTypeEnum.fromJson(json[r'provider'])!,
        subType: AccountSubTypeEnum.fromJson(json[r'subType']),
        interestRate: json[r'interestRate'] == null
            ? null
            : num.parse('${json[r'interestRate']}'),
        name: mapValueOfType<String>(json, r'name')!,
        institution: Institution.fromJson(json[r'institution'])!,
        currency: mapValueOfType<String>(json, r'currency')!,
        balance: num.parse('${json[r'balance']}'),
        availableBalance: num.parse('${json[r'availableBalance']}'),
        type: AccountTypeEnum.fromJson(json[r'type'])!,
        extra: mapValueOfType<Object>(json, r'extra'),
      );
    }
    return null;
  }

  static List<Account> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Account>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Account.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Account> mapFromJson(dynamic json) {
    final map = <String, Account>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Account.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Account-objects as value to a dart map
  static Map<String, List<Account>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Account>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Account.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'provider',
    'name',
    'institution',
    'currency',
    'balance',
    'availableBalance',
    'type',
  };
}

/// The type of this account to better separate it from the others.
class AccountTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const AccountTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const depository = AccountTypeEnum._(r'depository');
  static const credit = AccountTypeEnum._(r'credit');
  static const asset = AccountTypeEnum._(r'asset');
  static const loan = AccountTypeEnum._(r'loan');
  static const investment = AccountTypeEnum._(r'investment');
  static const crypto = AccountTypeEnum._(r'crypto');

  /// List of all possible values in this [enum][AccountTypeEnum].
  static const values = <AccountTypeEnum>[
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


