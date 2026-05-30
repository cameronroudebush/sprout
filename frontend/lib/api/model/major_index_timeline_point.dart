//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MajorIndexTimelinePoint {
  /// Returns a new [MajorIndexTimelinePoint] instance.
  MajorIndexTimelinePoint({
    required this.date,
    required this.value,
    required this.changePercent,
  });

  DateTime date;

  /// The raw closing nominal price.
  num value;

  /// The percentage change relative to day one of the lookback window.
  num changePercent;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MajorIndexTimelinePoint &&
    other.date == date &&
    other.value == value &&
    other.changePercent == changePercent;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (date.hashCode) +
    (value.hashCode) +
    (changePercent.hashCode);

  @override
  String toString() => 'MajorIndexTimelinePoint[date=$date, value=$value, changePercent=$changePercent]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'date'] = this.date.toUtc().toIso8601String();
      json[r'value'] = this.value;
      json[r'changePercent'] = this.changePercent;
    return json;
  }

  /// Returns a new [MajorIndexTimelinePoint] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MajorIndexTimelinePoint? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'date'), 'Required key "MajorIndexTimelinePoint[date]" is missing from JSON.');
        assert(json[r'date'] != null, 'Required key "MajorIndexTimelinePoint[date]" has a null value in JSON.');
        assert(json.containsKey(r'value'), 'Required key "MajorIndexTimelinePoint[value]" is missing from JSON.');
        assert(json[r'value'] != null, 'Required key "MajorIndexTimelinePoint[value]" has a null value in JSON.');
        assert(json.containsKey(r'changePercent'), 'Required key "MajorIndexTimelinePoint[changePercent]" is missing from JSON.');
        assert(json[r'changePercent'] != null, 'Required key "MajorIndexTimelinePoint[changePercent]" has a null value in JSON.');
        return true;
      }());

      return MajorIndexTimelinePoint(
        date: mapDateTime(json, r'date', r'')!,
        value: num.parse('${json[r'value']}'),
        changePercent: num.parse('${json[r'changePercent']}'),
      );
    }
    return null;
  }

  static List<MajorIndexTimelinePoint> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MajorIndexTimelinePoint>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MajorIndexTimelinePoint.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MajorIndexTimelinePoint> mapFromJson(dynamic json) {
    final map = <String, MajorIndexTimelinePoint>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MajorIndexTimelinePoint.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MajorIndexTimelinePoint-objects as value to a dart map
  static Map<String, List<MajorIndexTimelinePoint>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MajorIndexTimelinePoint>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MajorIndexTimelinePoint.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'date',
    'value',
    'changePercent',
  };
}

