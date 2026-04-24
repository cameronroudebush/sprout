//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class APIConfig {
  /// Returns a new [APIConfig] instance.
  APIConfig({
    required this.chatKeyProvidedInBackend,
    required this.emailEnabled,
  });

  /// Determines if the chat key is already provided and users shouldn't be able to set theirs then.
  bool chatKeyProvidedInBackend;

  /// Tracks if email is enabled and functional
  bool emailEnabled;

  @override
  bool operator ==(Object other) => identical(this, other) || other is APIConfig &&
    other.chatKeyProvidedInBackend == chatKeyProvidedInBackend &&
    other.emailEnabled == emailEnabled;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (chatKeyProvidedInBackend.hashCode) +
    (emailEnabled.hashCode);

  @override
  String toString() => 'APIConfig[chatKeyProvidedInBackend=$chatKeyProvidedInBackend, emailEnabled=$emailEnabled]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'chatKeyProvidedInBackend'] = this.chatKeyProvidedInBackend;
      json[r'emailEnabled'] = this.emailEnabled;
    return json;
  }

  /// Returns a new [APIConfig] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static APIConfig? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'chatKeyProvidedInBackend'), 'Required key "APIConfig[chatKeyProvidedInBackend]" is missing from JSON.');
        assert(json[r'chatKeyProvidedInBackend'] != null, 'Required key "APIConfig[chatKeyProvidedInBackend]" has a null value in JSON.');
        assert(json.containsKey(r'emailEnabled'), 'Required key "APIConfig[emailEnabled]" is missing from JSON.');
        assert(json[r'emailEnabled'] != null, 'Required key "APIConfig[emailEnabled]" has a null value in JSON.');
        return true;
      }());

      return APIConfig(
        chatKeyProvidedInBackend: mapValueOfType<bool>(json, r'chatKeyProvidedInBackend')!,
        emailEnabled: mapValueOfType<bool>(json, r'emailEnabled')!,
      );
    }
    return null;
  }

  static List<APIConfig> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <APIConfig>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = APIConfig.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, APIConfig> mapFromJson(dynamic json) {
    final map = <String, APIConfig>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = APIConfig.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of APIConfig-objects as value to a dart map
  static Map<String, List<APIConfig>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<APIConfig>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = APIConfig.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'chatKeyProvidedInBackend',
    'emailEnabled',
  };
}

