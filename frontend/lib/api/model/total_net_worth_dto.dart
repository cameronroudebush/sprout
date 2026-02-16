//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TotalNetWorthDTO {
  /// Returns a new [TotalNetWorthDTO] instance.
  TotalNetWorthDTO({
    required this.value,
    required this.history,
    this.timeline = const [],
  });

  num value;

  EntityHistory history;

  List<HistoricalDataPoint> timeline;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TotalNetWorthDTO &&
    other.value == value &&
    other.history == history &&
    _deepEquality.equals(other.timeline, timeline);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (value.hashCode) +
    (history.hashCode) +
    (timeline.hashCode);

  @override
  String toString() => 'TotalNetWorthDTO[value=$value, history=$history, timeline=$timeline]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'value'] = this.value;
      json[r'history'] = this.history;
      json[r'timeline'] = this.timeline;
    return json;
  }

  /// Returns a new [TotalNetWorthDTO] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TotalNetWorthDTO? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TotalNetWorthDTO[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TotalNetWorthDTO[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return TotalNetWorthDTO(
        value: num.parse('${json[r'value']}'),
        history: EntityHistory.fromJson(json[r'history'])!,
        timeline: HistoricalDataPoint.listFromJson(json[r'timeline']),
      );
    }
    return null;
  }

  static List<TotalNetWorthDTO> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TotalNetWorthDTO>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TotalNetWorthDTO.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TotalNetWorthDTO> mapFromJson(dynamic json) {
    final map = <String, TotalNetWorthDTO>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TotalNetWorthDTO.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TotalNetWorthDTO-objects as value to a dart map
  static Map<String, List<TotalNetWorthDTO>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TotalNetWorthDTO>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TotalNetWorthDTO.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'value',
    'history',
    'timeline',
  };
}

