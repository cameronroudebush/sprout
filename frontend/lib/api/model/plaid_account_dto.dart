//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PlaidAccountDTO {
  /// Returns a new [PlaidAccountDTO] instance.
  PlaidAccountDTO({
    required this.id,
    required this.name,
    this.mask,
    required this.type,
    required this.subtype,
  });

  String id;

  String name;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? mask;

  String type;

  String subtype;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PlaidAccountDTO &&
    other.id == id &&
    other.name == name &&
    other.mask == mask &&
    other.type == type &&
    other.subtype == subtype;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (mask == null ? 0 : mask!.hashCode) +
    (type.hashCode) +
    (subtype.hashCode);

  @override
  String toString() => 'PlaidAccountDTO[id=$id, name=$name, mask=$mask, type=$type, subtype=$subtype]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
    if (this.mask != null) {
      json[r'mask'] = this.mask;
    } else {
      json[r'mask'] = null;
    }
      json[r'type'] = this.type;
      json[r'subtype'] = this.subtype;
    return json;
  }

  /// Returns a new [PlaidAccountDTO] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PlaidAccountDTO? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "PlaidAccountDTO[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "PlaidAccountDTO[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "PlaidAccountDTO[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "PlaidAccountDTO[name]" has a null value in JSON.');
        assert(json.containsKey(r'type'), 'Required key "PlaidAccountDTO[type]" is missing from JSON.');
        assert(json[r'type'] != null, 'Required key "PlaidAccountDTO[type]" has a null value in JSON.');
        assert(json.containsKey(r'subtype'), 'Required key "PlaidAccountDTO[subtype]" is missing from JSON.');
        assert(json[r'subtype'] != null, 'Required key "PlaidAccountDTO[subtype]" has a null value in JSON.');
        return true;
      }());

      return PlaidAccountDTO(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        mask: mapValueOfType<String>(json, r'mask'),
        type: mapValueOfType<String>(json, r'type')!,
        subtype: mapValueOfType<String>(json, r'subtype')!,
      );
    }
    return null;
  }

  static List<PlaidAccountDTO> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PlaidAccountDTO>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PlaidAccountDTO.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PlaidAccountDTO> mapFromJson(dynamic json) {
    final map = <String, PlaidAccountDTO>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PlaidAccountDTO.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PlaidAccountDTO-objects as value to a dart map
  static Map<String, List<PlaidAccountDTO>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PlaidAccountDTO>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PlaidAccountDTO.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'type',
    'subtype',
  };
}

