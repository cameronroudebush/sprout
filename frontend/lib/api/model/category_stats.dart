//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CategoryStats {
  /// Returns a new [CategoryStats] instance.
  CategoryStats({
    this.categoryCount = const {},
    this.colorMapping = const {},
  });

  /// The number of transactions matching to each category
  Map<String, num> categoryCount;

  /// Color information for each category, in hex codes
  Map<String, String> colorMapping;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CategoryStats &&
    _deepEquality.equals(other.categoryCount, categoryCount) &&
    _deepEquality.equals(other.colorMapping, colorMapping);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (categoryCount.hashCode) +
    (colorMapping.hashCode);

  @override
  String toString() => 'CategoryStats[categoryCount=$categoryCount, colorMapping=$colorMapping]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'categoryCount'] = this.categoryCount;
      json[r'colorMapping'] = this.colorMapping;
    return json;
  }

  /// Returns a new [CategoryStats] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CategoryStats? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CategoryStats[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CategoryStats[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CategoryStats(
        categoryCount: mapCastOfType<String, num>(json, r'categoryCount')!,
        colorMapping: mapCastOfType<String, String>(json, r'colorMapping')!,
      );
    }
    return null;
  }

  static List<CategoryStats> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CategoryStats>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CategoryStats.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CategoryStats> mapFromJson(dynamic json) {
    final map = <String, CategoryStats>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CategoryStats.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CategoryStats-objects as value to a dart map
  static Map<String, List<CategoryStats>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CategoryStats>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CategoryStats.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'categoryCount',
    'colorMapping',
  };
}

