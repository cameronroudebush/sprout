//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class EntityHistory {
  /// Returns a new [EntityHistory] instance.
  EntityHistory({
    required this.last1Day,
    required this.last7Days,
    required this.lastMonth,
    required this.lastThreeMonths,
    required this.lastSixMonths,
    required this.lastYear,
    required this.allTime,
    this.connectedId,
  });

  EntityHistoryDataPoint last1Day;

  EntityHistoryDataPoint last7Days;

  EntityHistoryDataPoint lastMonth;

  EntityHistoryDataPoint lastThreeMonths;

  EntityHistoryDataPoint lastSixMonths;

  EntityHistoryDataPoint lastYear;

  EntityHistoryDataPoint allTime;

  /// Some entity history data may have a connected Id of what it relates to. This could be something like an account Id.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? connectedId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EntityHistory &&
    other.last1Day == last1Day &&
    other.last7Days == last7Days &&
    other.lastMonth == lastMonth &&
    other.lastThreeMonths == lastThreeMonths &&
    other.lastSixMonths == lastSixMonths &&
    other.lastYear == lastYear &&
    other.allTime == allTime &&
    other.connectedId == connectedId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (last1Day.hashCode) +
    (last7Days.hashCode) +
    (lastMonth.hashCode) +
    (lastThreeMonths.hashCode) +
    (lastSixMonths.hashCode) +
    (lastYear.hashCode) +
    (allTime.hashCode) +
    (connectedId == null ? 0 : connectedId!.hashCode);

  @override
  String toString() => 'EntityHistory[last1Day=$last1Day, last7Days=$last7Days, lastMonth=$lastMonth, lastThreeMonths=$lastThreeMonths, lastSixMonths=$lastSixMonths, lastYear=$lastYear, allTime=$allTime, connectedId=$connectedId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'last1Day'] = this.last1Day;
      json[r'last7Days'] = this.last7Days;
      json[r'lastMonth'] = this.lastMonth;
      json[r'lastThreeMonths'] = this.lastThreeMonths;
      json[r'lastSixMonths'] = this.lastSixMonths;
      json[r'lastYear'] = this.lastYear;
      json[r'allTime'] = this.allTime;
    if (this.connectedId != null) {
      json[r'connectedId'] = this.connectedId;
    } else {
      json[r'connectedId'] = null;
    }
    return json;
  }

  /// Returns a new [EntityHistory] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EntityHistory? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "EntityHistory[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "EntityHistory[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return EntityHistory(
        last1Day: EntityHistoryDataPoint.fromJson(json[r'last1Day'])!,
        last7Days: EntityHistoryDataPoint.fromJson(json[r'last7Days'])!,
        lastMonth: EntityHistoryDataPoint.fromJson(json[r'lastMonth'])!,
        lastThreeMonths: EntityHistoryDataPoint.fromJson(json[r'lastThreeMonths'])!,
        lastSixMonths: EntityHistoryDataPoint.fromJson(json[r'lastSixMonths'])!,
        lastYear: EntityHistoryDataPoint.fromJson(json[r'lastYear'])!,
        allTime: EntityHistoryDataPoint.fromJson(json[r'allTime'])!,
        connectedId: mapValueOfType<String>(json, r'connectedId'),
      );
    }
    return null;
  }

  static List<EntityHistory> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EntityHistory>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EntityHistory.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EntityHistory> mapFromJson(dynamic json) {
    final map = <String, EntityHistory>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EntityHistory.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EntityHistory-objects as value to a dart map
  static Map<String, List<EntityHistory>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EntityHistory>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EntityHistory.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'last1Day',
    'last7Days',
    'lastMonth',
    'lastThreeMonths',
    'lastSixMonths',
    'lastYear',
    'allTime',
  };
}

