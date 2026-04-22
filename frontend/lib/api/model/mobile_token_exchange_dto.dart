//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MobileTokenExchangeDto {
  /// Returns a new [MobileTokenExchangeDto] instance.
  MobileTokenExchangeDto({
    required this.code,
    required this.appVerifier,
  });

  String code;

  String appVerifier;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MobileTokenExchangeDto &&
    other.code == code &&
    other.appVerifier == appVerifier;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (appVerifier.hashCode);

  @override
  String toString() => 'MobileTokenExchangeDto[code=$code, appVerifier=$appVerifier]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'appVerifier'] = this.appVerifier;
    return json;
  }

  /// Returns a new [MobileTokenExchangeDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MobileTokenExchangeDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'code'), 'Required key "MobileTokenExchangeDto[code]" is missing from JSON.');
        assert(json[r'code'] != null, 'Required key "MobileTokenExchangeDto[code]" has a null value in JSON.');
        assert(json.containsKey(r'appVerifier'), 'Required key "MobileTokenExchangeDto[appVerifier]" is missing from JSON.');
        assert(json[r'appVerifier'] != null, 'Required key "MobileTokenExchangeDto[appVerifier]" has a null value in JSON.');
        return true;
      }());

      return MobileTokenExchangeDto(
        code: mapValueOfType<String>(json, r'code')!,
        appVerifier: mapValueOfType<String>(json, r'appVerifier')!,
      );
    }
    return null;
  }

  static List<MobileTokenExchangeDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MobileTokenExchangeDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MobileTokenExchangeDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MobileTokenExchangeDto> mapFromJson(dynamic json) {
    final map = <String, MobileTokenExchangeDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MobileTokenExchangeDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MobileTokenExchangeDto-objects as value to a dart map
  static Map<String, List<MobileTokenExchangeDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MobileTokenExchangeDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MobileTokenExchangeDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'appVerifier',
  };
}

