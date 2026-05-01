//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ZillowPropertyResultDto {
  /// Returns a new [ZillowPropertyResultDto] instance.
  ZillowPropertyResultDto({
    required this.zestimate,
    required this.rentZestimate,
    required this.zpid,
  });

  /// The numeric value converted to the user's preferred currency format. This overrides the original zestimate property.
  num zestimate;

  /// The numeric value converted to the user's preferred currency format. This overrides the original rentZestimate property.
  num rentZestimate;

  String zpid;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ZillowPropertyResultDto &&
    other.zestimate == zestimate &&
    other.rentZestimate == rentZestimate &&
    other.zpid == zpid;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (zestimate.hashCode) +
    (rentZestimate.hashCode) +
    (zpid.hashCode);

  @override
  String toString() => 'ZillowPropertyResultDto[zestimate=$zestimate, rentZestimate=$rentZestimate, zpid=$zpid]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'zestimate'] = this.zestimate;
      json[r'rentZestimate'] = this.rentZestimate;
      json[r'zpid'] = this.zpid;
    return json;
  }

  /// Returns a new [ZillowPropertyResultDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ZillowPropertyResultDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'zestimate'), 'Required key "ZillowPropertyResultDto[zestimate]" is missing from JSON.');
        assert(json[r'zestimate'] != null, 'Required key "ZillowPropertyResultDto[zestimate]" has a null value in JSON.');
        assert(json.containsKey(r'rentZestimate'), 'Required key "ZillowPropertyResultDto[rentZestimate]" is missing from JSON.');
        assert(json[r'rentZestimate'] != null, 'Required key "ZillowPropertyResultDto[rentZestimate]" has a null value in JSON.');
        assert(json.containsKey(r'zpid'), 'Required key "ZillowPropertyResultDto[zpid]" is missing from JSON.');
        assert(json[r'zpid'] != null, 'Required key "ZillowPropertyResultDto[zpid]" has a null value in JSON.');
        return true;
      }());

      return ZillowPropertyResultDto(
        zestimate: num.parse('${json[r'zestimate']}'),
        rentZestimate: num.parse('${json[r'rentZestimate']}'),
        zpid: mapValueOfType<String>(json, r'zpid')!,
      );
    }
    return null;
  }

  static List<ZillowPropertyResultDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ZillowPropertyResultDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ZillowPropertyResultDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ZillowPropertyResultDto> mapFromJson(dynamic json) {
    final map = <String, ZillowPropertyResultDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ZillowPropertyResultDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ZillowPropertyResultDto-objects as value to a dart map
  static Map<String, List<ZillowPropertyResultDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ZillowPropertyResultDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ZillowPropertyResultDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'zestimate',
    'rentZestimate',
    'zpid',
  };
}

