//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AccountEditRequest {
  /// Returns a new [AccountEditRequest] instance.
  AccountEditRequest({
    this.subType,
    this.name,
  });

  /// The specific subtype of the account
  AccountEditRequestSubTypeEnum? subType;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AccountEditRequest &&
    other.subType == subType &&
    other.name == name;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (subType == null ? 0 : subType!.hashCode) +
    (name == null ? 0 : name!.hashCode);

  @override
  String toString() => 'AccountEditRequest[subType=$subType, name=$name]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.subType != null) {
      json[r'subType'] = this.subType;
    } else {
      json[r'subType'] = null;
    }
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    return json;
  }

  /// Returns a new [AccountEditRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AccountEditRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AccountEditRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AccountEditRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AccountEditRequest(
        subType: AccountEditRequestSubTypeEnum.fromJson(json[r'subType']),
        name: mapValueOfType<String>(json, r'name'),
      );
    }
    return null;
  }

  static List<AccountEditRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AccountEditRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AccountEditRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AccountEditRequest> mapFromJson(dynamic json) {
    final map = <String, AccountEditRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AccountEditRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AccountEditRequest-objects as value to a dart map
  static Map<String, List<AccountEditRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AccountEditRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AccountEditRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

/// The specific subtype of the account
class AccountEditRequestSubTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const AccountEditRequestSubTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const savings = AccountEditRequestSubTypeEnum._(r'Savings');
  static const checking = AccountEditRequestSubTypeEnum._(r'Checking');
  static const HYSA = AccountEditRequestSubTypeEnum._(r'HYSA');
  static const n401k = AccountEditRequestSubTypeEnum._(r'401K');
  static const brokerage = AccountEditRequestSubTypeEnum._(r'Brokerage');
  static const IRA = AccountEditRequestSubTypeEnum._(r'IRA');
  static const HSA = AccountEditRequestSubTypeEnum._(r'HSA');
  static const student = AccountEditRequestSubTypeEnum._(r'Student');
  static const mortgage = AccountEditRequestSubTypeEnum._(r'Mortgage');
  static const personal = AccountEditRequestSubTypeEnum._(r'Personal');
  static const auto = AccountEditRequestSubTypeEnum._(r'Auto');
  static const travel = AccountEditRequestSubTypeEnum._(r'Travel');
  static const cashBack = AccountEditRequestSubTypeEnum._(r'Cash Back');
  static const wallet = AccountEditRequestSubTypeEnum._(r'Wallet');
  static const staking = AccountEditRequestSubTypeEnum._(r'Staking');

  /// List of all possible values in this [enum][AccountEditRequestSubTypeEnum].
  static const values = <AccountEditRequestSubTypeEnum>[
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

  static AccountEditRequestSubTypeEnum? fromJson(dynamic value) => AccountEditRequestSubTypeEnumTypeTransformer().decode(value);

  static List<AccountEditRequestSubTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AccountEditRequestSubTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AccountEditRequestSubTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AccountEditRequestSubTypeEnum] to String,
/// and [decode] dynamic data back to [AccountEditRequestSubTypeEnum].
class AccountEditRequestSubTypeEnumTypeTransformer {
  factory AccountEditRequestSubTypeEnumTypeTransformer() => _instance ??= const AccountEditRequestSubTypeEnumTypeTransformer._();

  const AccountEditRequestSubTypeEnumTypeTransformer._();

  String encode(AccountEditRequestSubTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AccountEditRequestSubTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AccountEditRequestSubTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'Savings': return AccountEditRequestSubTypeEnum.savings;
        case r'Checking': return AccountEditRequestSubTypeEnum.checking;
        case r'HYSA': return AccountEditRequestSubTypeEnum.HYSA;
        case r'401K': return AccountEditRequestSubTypeEnum.n401k;
        case r'Brokerage': return AccountEditRequestSubTypeEnum.brokerage;
        case r'IRA': return AccountEditRequestSubTypeEnum.IRA;
        case r'HSA': return AccountEditRequestSubTypeEnum.HSA;
        case r'Student': return AccountEditRequestSubTypeEnum.student;
        case r'Mortgage': return AccountEditRequestSubTypeEnum.mortgage;
        case r'Personal': return AccountEditRequestSubTypeEnum.personal;
        case r'Auto': return AccountEditRequestSubTypeEnum.auto;
        case r'Travel': return AccountEditRequestSubTypeEnum.travel;
        case r'Cash Back': return AccountEditRequestSubTypeEnum.cashBack;
        case r'Wallet': return AccountEditRequestSubTypeEnum.wallet;
        case r'Staking': return AccountEditRequestSubTypeEnum.staking;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AccountEditRequestSubTypeEnumTypeTransformer] instance.
  static AccountEditRequestSubTypeEnumTypeTransformer? _instance;
}


