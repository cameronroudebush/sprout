//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateInstitutionRequest {
  /// Returns a new [UpdateInstitutionRequest] instance.
  UpdateInstitutionRequest({
    required this.iconType,
  });

  /// The preferred logo variant style for this institution.
  InstitutionIconType iconType;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateInstitutionRequest &&
    other.iconType == iconType;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (iconType.hashCode);

  @override
  String toString() => 'UpdateInstitutionRequest[iconType=$iconType]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'iconType'] = this.iconType;
    return json;
  }

  /// Returns a new [UpdateInstitutionRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateInstitutionRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'iconType'), 'Required key "UpdateInstitutionRequest[iconType]" is missing from JSON.');
        assert(json[r'iconType'] != null, 'Required key "UpdateInstitutionRequest[iconType]" has a null value in JSON.');
        return true;
      }());

      return UpdateInstitutionRequest(
        iconType: InstitutionIconType.fromJson(json[r'iconType'])!,
      );
    }
    return null;
  }

  static List<UpdateInstitutionRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateInstitutionRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateInstitutionRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateInstitutionRequest> mapFromJson(dynamic json) {
    final map = <String, UpdateInstitutionRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateInstitutionRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateInstitutionRequest-objects as value to a dart map
  static Map<String, List<UpdateInstitutionRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateInstitutionRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateInstitutionRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'iconType',
  };
}

