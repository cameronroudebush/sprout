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
    this.interestRate,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  AccountSubTypeEnum? subType;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? interestRate;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AccountEditRequest &&
    other.subType == subType &&
    other.name == name &&
    other.interestRate == interestRate;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (subType == null ? 0 : subType!.hashCode) +
    (name == null ? 0 : name!.hashCode) +
    (interestRate == null ? 0 : interestRate!.hashCode);

  @override
  String toString() => 'AccountEditRequest[subType=$subType, name=$name, interestRate=$interestRate]';

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
    if (this.interestRate != null) {
      json[r'interestRate'] = this.interestRate;
    } else {
      json[r'interestRate'] = null;
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
        subType: AccountSubTypeEnum.fromJson(json[r'subType']),
        name: mapValueOfType<String>(json, r'name'),
        interestRate: num.parse('${json[r'interestRate']}'),
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

