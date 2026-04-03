//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ZillowAsset {
  /// Returns a new [ZillowAsset] instance.
  ZillowAsset({
    required this.id,
    required this.zpid,
  });

  String id;

  /// The zillow property ID
  String zpid;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ZillowAsset &&
    other.id == id &&
    other.zpid == zpid;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (zpid.hashCode);

  @override
  String toString() => 'ZillowAsset[id=$id, zpid=$zpid]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'zpid'] = this.zpid;
    return json;
  }

  /// Returns a new [ZillowAsset] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ZillowAsset? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ZillowAsset[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ZillowAsset[id]" has a null value in JSON.');
        assert(json.containsKey(r'zpid'), 'Required key "ZillowAsset[zpid]" is missing from JSON.');
        assert(json[r'zpid'] != null, 'Required key "ZillowAsset[zpid]" has a null value in JSON.');
        return true;
      }());

      return ZillowAsset(
        id: mapValueOfType<String>(json, r'id')!,
        zpid: mapValueOfType<String>(json, r'zpid')!,
      );
    }
    return null;
  }

  static List<ZillowAsset> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ZillowAsset>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ZillowAsset.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ZillowAsset> mapFromJson(dynamic json) {
    final map = <String, ZillowAsset>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ZillowAsset.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ZillowAsset-objects as value to a dart map
  static Map<String, List<ZillowAsset>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ZillowAsset>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ZillowAsset.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'zpid',
  };
}

