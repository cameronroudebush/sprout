//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PlaidInstitutionDTO {
  /// Returns a new [PlaidInstitutionDTO] instance.
  PlaidInstitutionDTO({
    required this.name,
    required this.institutionId,
  });

  String name;

  String institutionId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PlaidInstitutionDTO &&
    other.name == name &&
    other.institutionId == institutionId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (institutionId.hashCode);

  @override
  String toString() => 'PlaidInstitutionDTO[name=$name, institutionId=$institutionId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'institution_id'] = this.institutionId;
    return json;
  }

  /// Returns a new [PlaidInstitutionDTO] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PlaidInstitutionDTO? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "PlaidInstitutionDTO[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "PlaidInstitutionDTO[name]" has a null value in JSON.');
        assert(json.containsKey(r'institution_id'), 'Required key "PlaidInstitutionDTO[institution_id]" is missing from JSON.');
        assert(json[r'institution_id'] != null, 'Required key "PlaidInstitutionDTO[institution_id]" has a null value in JSON.');
        return true;
      }());

      return PlaidInstitutionDTO(
        name: mapValueOfType<String>(json, r'name')!,
        institutionId: mapValueOfType<String>(json, r'institution_id')!,
      );
    }
    return null;
  }

  static List<PlaidInstitutionDTO> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PlaidInstitutionDTO>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PlaidInstitutionDTO.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PlaidInstitutionDTO> mapFromJson(dynamic json) {
    final map = <String, PlaidInstitutionDTO>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PlaidInstitutionDTO.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PlaidInstitutionDTO-objects as value to a dart map
  static Map<String, List<PlaidInstitutionDTO>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PlaidInstitutionDTO>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PlaidInstitutionDTO.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'institution_id',
  };
}

