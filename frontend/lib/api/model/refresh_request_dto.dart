//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RefreshRequestDTO {
  /// Returns a new [RefreshRequestDTO] instance.
  RefreshRequestDTO({
    required this.refreshToken,
  });

  /// The current refresh token
  String refreshToken;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RefreshRequestDTO &&
    other.refreshToken == refreshToken;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (refreshToken.hashCode);

  @override
  String toString() => 'RefreshRequestDTO[refreshToken=$refreshToken]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'refreshToken'] = this.refreshToken;
    return json;
  }

  /// Returns a new [RefreshRequestDTO] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RefreshRequestDTO? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RefreshRequestDTO[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RefreshRequestDTO[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RefreshRequestDTO(
        refreshToken: mapValueOfType<String>(json, r'refreshToken')!,
      );
    }
    return null;
  }

  static List<RefreshRequestDTO> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RefreshRequestDTO>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RefreshRequestDTO.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RefreshRequestDTO> mapFromJson(dynamic json) {
    final map = <String, RefreshRequestDTO>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RefreshRequestDTO.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RefreshRequestDTO-objects as value to a dart map
  static Map<String, List<RefreshRequestDTO>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RefreshRequestDTO>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RefreshRequestDTO.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'refreshToken',
  };
}

