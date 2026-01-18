//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UnsecureAppConfiguration {
  /// Returns a new [UnsecureAppConfiguration] instance.
  UnsecureAppConfiguration({
    required this.firstTimeSetupPosition,
    required this.version,
    this.oidcConfig,
  });

  /// If this is the first time someone has connected to this interface
  Object firstTimeSetupPosition;

  /// Version of the backend
  String version;

  /// The OIDC configuration if the server is instead setup to do that.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  UnsecureOIDCConfig? oidcConfig;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UnsecureAppConfiguration &&
    other.firstTimeSetupPosition == firstTimeSetupPosition &&
    other.version == version &&
    other.oidcConfig == oidcConfig;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (firstTimeSetupPosition.hashCode) +
    (version.hashCode) +
    (oidcConfig == null ? 0 : oidcConfig!.hashCode);

  @override
  String toString() => 'UnsecureAppConfiguration[firstTimeSetupPosition=$firstTimeSetupPosition, version=$version, oidcConfig=$oidcConfig]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'firstTimeSetupPosition'] = this.firstTimeSetupPosition;
      json[r'version'] = this.version;
    if (this.oidcConfig != null) {
      json[r'oidcConfig'] = this.oidcConfig;
    } else {
      json[r'oidcConfig'] = null;
    }
    return json;
  }

  /// Returns a new [UnsecureAppConfiguration] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UnsecureAppConfiguration? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UnsecureAppConfiguration[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UnsecureAppConfiguration[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UnsecureAppConfiguration(
        firstTimeSetupPosition: mapValueOfType<Object>(json, r'firstTimeSetupPosition')!,
        version: mapValueOfType<String>(json, r'version')!,
        oidcConfig: UnsecureOIDCConfig.fromJson(json[r'oidcConfig']),
      );
    }
    return null;
  }

  static List<UnsecureAppConfiguration> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UnsecureAppConfiguration>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UnsecureAppConfiguration.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UnsecureAppConfiguration> mapFromJson(dynamic json) {
    final map = <String, UnsecureAppConfiguration>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UnsecureAppConfiguration.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UnsecureAppConfiguration-objects as value to a dart map
  static Map<String, List<UnsecureAppConfiguration>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UnsecureAppConfiguration>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UnsecureAppConfiguration.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'firstTimeSetupPosition',
    'version',
  };
}

