//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class EntityHistoryDataPoint {
  /// Returns a new [EntityHistoryDataPoint] instance.
  EntityHistoryDataPoint({
    required this.start,
    this.percentChange,
    required this.valueChange,
  });

  /// When our data starts
  DateTime start;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? percentChange;

  num valueChange;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EntityHistoryDataPoint &&
    other.start == start &&
    other.percentChange == percentChange &&
    other.valueChange == valueChange;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (start.hashCode) +
    (percentChange == null ? 0 : percentChange!.hashCode) +
    (valueChange.hashCode);

  @override
  String toString() => 'EntityHistoryDataPoint[start=$start, percentChange=$percentChange, valueChange=$valueChange]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'start'] = this.start.toUtc().toIso8601String();
    if (this.percentChange != null) {
      json[r'percentChange'] = this.percentChange;
    } else {
      json[r'percentChange'] = null;
    }
      json[r'valueChange'] = this.valueChange;
    return json;
  }

  /// Returns a new [EntityHistoryDataPoint] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EntityHistoryDataPoint? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "EntityHistoryDataPoint[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "EntityHistoryDataPoint[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return EntityHistoryDataPoint(
        start: mapDateTime(json, r'start', r'')!,
        percentChange: num.parse('${json[r'percentChange']}'),
        valueChange: num.parse('${json[r'valueChange']}'),
      );
    }
    return null;
  }

  static List<EntityHistoryDataPoint> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EntityHistoryDataPoint>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EntityHistoryDataPoint.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EntityHistoryDataPoint> mapFromJson(dynamic json) {
    final map = <String, EntityHistoryDataPoint>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EntityHistoryDataPoint.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EntityHistoryDataPoint-objects as value to a dart map
  static Map<String, List<EntityHistoryDataPoint>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EntityHistoryDataPoint>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EntityHistoryDataPoint.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'start',
    'valueChange',
  };
}

