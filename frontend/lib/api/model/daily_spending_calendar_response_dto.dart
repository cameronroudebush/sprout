//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DailySpendingCalendarResponseDTO {
  /// Returns a new [DailySpendingCalendarResponseDTO] instance.
  DailySpendingCalendarResponseDTO({
    this.spending = const [],
  });

  /// List of days containing spending metrics for the target month.
  List<DailySpendingItem> spending;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DailySpendingCalendarResponseDTO &&
    _deepEquality.equals(other.spending, spending);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (spending.hashCode);

  @override
  String toString() => 'DailySpendingCalendarResponseDTO[spending=$spending]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'spending'] = this.spending;
    return json;
  }

  /// Returns a new [DailySpendingCalendarResponseDTO] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DailySpendingCalendarResponseDTO? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'spending'), 'Required key "DailySpendingCalendarResponseDTO[spending]" is missing from JSON.');
        assert(json[r'spending'] != null, 'Required key "DailySpendingCalendarResponseDTO[spending]" has a null value in JSON.');
        return true;
      }());

      return DailySpendingCalendarResponseDTO(
        spending: DailySpendingItem.listFromJson(json[r'spending']),
      );
    }
    return null;
  }

  static List<DailySpendingCalendarResponseDTO> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DailySpendingCalendarResponseDTO>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DailySpendingCalendarResponseDTO.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DailySpendingCalendarResponseDTO> mapFromJson(dynamic json) {
    final map = <String, DailySpendingCalendarResponseDTO>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DailySpendingCalendarResponseDTO.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DailySpendingCalendarResponseDTO-objects as value to a dart map
  static Map<String, List<DailySpendingCalendarResponseDTO>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DailySpendingCalendarResponseDTO>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DailySpendingCalendarResponseDTO.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'spending',
  };
}

