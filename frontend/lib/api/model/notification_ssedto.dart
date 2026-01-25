//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class NotificationSSEDTO {
  /// Returns a new [NotificationSSEDTO] instance.
  NotificationSSEDTO({
    required this.popupLatest,
  });

  /// If we should render the latest notification or not
  bool popupLatest;

  @override
  bool operator ==(Object other) => identical(this, other) || other is NotificationSSEDTO &&
    other.popupLatest == popupLatest;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (popupLatest.hashCode);

  @override
  String toString() => 'NotificationSSEDTO[popupLatest=$popupLatest]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'popupLatest'] = this.popupLatest;
    return json;
  }

  /// Returns a new [NotificationSSEDTO] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NotificationSSEDTO? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "NotificationSSEDTO[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "NotificationSSEDTO[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return NotificationSSEDTO(
        popupLatest: mapValueOfType<bool>(json, r'popupLatest')!,
      );
    }
    return null;
  }

  static List<NotificationSSEDTO> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NotificationSSEDTO>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NotificationSSEDTO.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NotificationSSEDTO> mapFromJson(dynamic json) {
    final map = <String, NotificationSSEDTO>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NotificationSSEDTO.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NotificationSSEDTO-objects as value to a dart map
  static Map<String, List<NotificationSSEDTO>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<NotificationSSEDTO>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NotificationSSEDTO.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'popupLatest',
  };
}

