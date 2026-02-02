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
    required this.authMode,
    required this.version,
    required this.allowUserCreation,
  });

  UnsecureAppConfigurationAuthModeEnum authMode;

  /// Version of the backend
  String version;

  bool allowUserCreation;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UnsecureAppConfiguration &&
    other.authMode == authMode &&
    other.version == version &&
    other.allowUserCreation == allowUserCreation;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authMode.hashCode) +
    (version.hashCode) +
    (allowUserCreation.hashCode);

  @override
  String toString() => 'UnsecureAppConfiguration[authMode=$authMode, version=$version, allowUserCreation=$allowUserCreation]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authMode'] = this.authMode;
      json[r'version'] = this.version;
      json[r'allowUserCreation'] = this.allowUserCreation;
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
        authMode: UnsecureAppConfigurationAuthModeEnum.fromJson(json[r'authMode'])!,
        version: mapValueOfType<String>(json, r'version')!,
        allowUserCreation: mapValueOfType<bool>(json, r'allowUserCreation')!,
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
    'authMode',
    'version',
    'allowUserCreation',
  };
}


class UnsecureAppConfigurationAuthModeEnum {
  /// Instantiate a new enum with the provided [value].
  const UnsecureAppConfigurationAuthModeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const oidc = UnsecureAppConfigurationAuthModeEnum._(r'oidc');
  static const local = UnsecureAppConfigurationAuthModeEnum._(r'local');

  /// List of all possible values in this [enum][UnsecureAppConfigurationAuthModeEnum].
  static const values = <UnsecureAppConfigurationAuthModeEnum>[
    oidc,
    local,
  ];

  static UnsecureAppConfigurationAuthModeEnum? fromJson(dynamic value) => UnsecureAppConfigurationAuthModeEnumTypeTransformer().decode(value);

  static List<UnsecureAppConfigurationAuthModeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UnsecureAppConfigurationAuthModeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UnsecureAppConfigurationAuthModeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [UnsecureAppConfigurationAuthModeEnum] to String,
/// and [decode] dynamic data back to [UnsecureAppConfigurationAuthModeEnum].
class UnsecureAppConfigurationAuthModeEnumTypeTransformer {
  factory UnsecureAppConfigurationAuthModeEnumTypeTransformer() => _instance ??= const UnsecureAppConfigurationAuthModeEnumTypeTransformer._();

  const UnsecureAppConfigurationAuthModeEnumTypeTransformer._();

  String encode(UnsecureAppConfigurationAuthModeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a UnsecureAppConfigurationAuthModeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  UnsecureAppConfigurationAuthModeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'oidc': return UnsecureAppConfigurationAuthModeEnum.oidc;
        case r'local': return UnsecureAppConfigurationAuthModeEnum.local;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [UnsecureAppConfigurationAuthModeEnumTypeTransformer] instance.
  static UnsecureAppConfigurationAuthModeEnumTypeTransformer? _instance;
}


