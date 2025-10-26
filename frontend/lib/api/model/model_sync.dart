//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ModelSync {
  /// Returns a new [ModelSync] instance.
  ModelSync({
    required this.id,
    required this.time,
    required this.status,
    required this.failureReason,
  });

  String id;

  /// When this was started
  DateTime time;

  Object status;

  String failureReason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ModelSync &&
    other.id == id &&
    other.time == time &&
    other.status == status &&
    other.failureReason == failureReason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (time.hashCode) +
    (status.hashCode) +
    (failureReason.hashCode);

  @override
  String toString() => 'ModelSync[id=$id, time=$time, status=$status, failureReason=$failureReason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'time'] = this.time.toUtc().toIso8601String();
      json[r'status'] = this.status;
      json[r'failureReason'] = this.failureReason;
    return json;
  }

  /// Returns a new [ModelSync] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ModelSync? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ModelSync[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ModelSync[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ModelSync(
        id: mapValueOfType<String>(json, r'id')!,
        time: mapDateTime(json, r'time', r'')!,
        status: mapValueOfType<Object>(json, r'status')!,
        failureReason: mapValueOfType<String>(json, r'failureReason')!,
      );
    }
    return null;
  }

  static List<ModelSync> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ModelSync>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ModelSync.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ModelSync> mapFromJson(dynamic json) {
    final map = <String, ModelSync>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ModelSync.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ModelSync-objects as value to a dart map
  static Map<String, List<ModelSync>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ModelSync>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ModelSync.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'time',
    'status',
    'failureReason',
  };
}

