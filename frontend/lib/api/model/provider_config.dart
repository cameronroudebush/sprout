//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ProviderConfig {
  /// Returns a new [ProviderConfig] instance.
  ProviderConfig({
    required this.dbType,
    required this.name,
    required this.logoUrl,
    this.accountFixUrl,
  });

  String dbType;

  /// The name of this provider
  String name;

  /// An endpoint of where to get this logo
  String logoUrl;

  /// The URL to be able to fix accounts
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? accountFixUrl;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProviderConfig &&
    other.dbType == dbType &&
    other.name == name &&
    other.logoUrl == logoUrl &&
    other.accountFixUrl == accountFixUrl;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (dbType.hashCode) +
    (name.hashCode) +
    (logoUrl.hashCode) +
    (accountFixUrl == null ? 0 : accountFixUrl!.hashCode);

  @override
  String toString() => 'ProviderConfig[dbType=$dbType, name=$name, logoUrl=$logoUrl, accountFixUrl=$accountFixUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'dbType'] = this.dbType;
      json[r'name'] = this.name;
      json[r'logoUrl'] = this.logoUrl;
    if (this.accountFixUrl != null) {
      json[r'accountFixUrl'] = this.accountFixUrl;
    } else {
      json[r'accountFixUrl'] = null;
    }
    return json;
  }

  /// Returns a new [ProviderConfig] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProviderConfig? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ProviderConfig[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ProviderConfig[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ProviderConfig(
        dbType: mapValueOfType<String>(json, r'dbType')!,
        name: mapValueOfType<String>(json, r'name')!,
        logoUrl: mapValueOfType<String>(json, r'logoUrl')!,
        accountFixUrl: mapValueOfType<String>(json, r'accountFixUrl'),
      );
    }
    return null;
  }

  static List<ProviderConfig> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProviderConfig>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProviderConfig.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProviderConfig> mapFromJson(dynamic json) {
    final map = <String, ProviderConfig>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProviderConfig.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProviderConfig-objects as value to a dart map
  static Map<String, List<ProviderConfig>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ProviderConfig>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProviderConfig.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'dbType',
    'name',
    'logoUrl',
  };
}

