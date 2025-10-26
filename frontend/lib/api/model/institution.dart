//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Institution {
  /// Returns a new [Institution] instance.
  Institution({
    required this.id,
    required this.url,
    required this.name,
    required this.hasError,
  });

  String id;

  /// The URL for where this institution is
  String url;

  String name;

  /// If this institution has connection errors and needs fixed
  bool hasError;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Institution &&
    other.id == id &&
    other.url == url &&
    other.name == name &&
    other.hasError == hasError;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (url.hashCode) +
    (name.hashCode) +
    (hasError.hashCode);

  @override
  String toString() => 'Institution[id=$id, url=$url, name=$name, hasError=$hasError]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'url'] = this.url;
      json[r'name'] = this.name;
      json[r'hasError'] = this.hasError;
    return json;
  }

  /// Returns a new [Institution] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Institution? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Institution[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Institution[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Institution(
        id: mapValueOfType<String>(json, r'id')!,
        url: mapValueOfType<String>(json, r'url')!,
        name: mapValueOfType<String>(json, r'name')!,
        hasError: mapValueOfType<bool>(json, r'hasError')!,
      );
    }
    return null;
  }

  static List<Institution> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Institution>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Institution.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Institution> mapFromJson(dynamic json) {
    final map = <String, Institution>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Institution.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Institution-objects as value to a dart map
  static Map<String, List<Institution>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Institution>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Institution.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'url',
    'name',
    'hasError',
  };
}

