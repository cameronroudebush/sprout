//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ZillowPropertyDTO {
  /// Returns a new [ZillowPropertyDTO] instance.
  ZillowPropertyDTO({
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
  });

  String address;

  String city;

  String state;

  num zip;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ZillowPropertyDTO &&
    other.address == address &&
    other.city == city &&
    other.state == state &&
    other.zip == zip;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (address.hashCode) +
    (city.hashCode) +
    (state.hashCode) +
    (zip.hashCode);

  @override
  String toString() => 'ZillowPropertyDTO[address=$address, city=$city, state=$state, zip=$zip]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'address'] = this.address;
      json[r'city'] = this.city;
      json[r'state'] = this.state;
      json[r'zip'] = this.zip;
    return json;
  }

  /// Returns a new [ZillowPropertyDTO] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ZillowPropertyDTO? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'address'), 'Required key "ZillowPropertyDTO[address]" is missing from JSON.');
        assert(json[r'address'] != null, 'Required key "ZillowPropertyDTO[address]" has a null value in JSON.');
        assert(json.containsKey(r'city'), 'Required key "ZillowPropertyDTO[city]" is missing from JSON.');
        assert(json[r'city'] != null, 'Required key "ZillowPropertyDTO[city]" has a null value in JSON.');
        assert(json.containsKey(r'state'), 'Required key "ZillowPropertyDTO[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "ZillowPropertyDTO[state]" has a null value in JSON.');
        assert(json.containsKey(r'zip'), 'Required key "ZillowPropertyDTO[zip]" is missing from JSON.');
        assert(json[r'zip'] != null, 'Required key "ZillowPropertyDTO[zip]" has a null value in JSON.');
        return true;
      }());

      return ZillowPropertyDTO(
        address: mapValueOfType<String>(json, r'address')!,
        city: mapValueOfType<String>(json, r'city')!,
        state: mapValueOfType<String>(json, r'state')!,
        zip: num.parse('${json[r'zip']}'),
      );
    }
    return null;
  }

  static List<ZillowPropertyDTO> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ZillowPropertyDTO>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ZillowPropertyDTO.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ZillowPropertyDTO> mapFromJson(dynamic json) {
    final map = <String, ZillowPropertyDTO>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ZillowPropertyDTO.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ZillowPropertyDTO-objects as value to a dart map
  static Map<String, List<ZillowPropertyDTO>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ZillowPropertyDTO>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ZillowPropertyDTO.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'address',
    'city',
    'state',
    'zip',
  };
}

