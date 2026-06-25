//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TransactionExtraData {
  /// Returns a new [TransactionExtraData] instance.
  TransactionExtraData({
    this.code,
    this.location,
  });

  String? code;

  TransactionLocation? location;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TransactionExtraData &&
    other.code == code &&
    other.location == location;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code == null ? 0 : code!.hashCode) +
    (location == null ? 0 : location!.hashCode);

  @override
  String toString() => 'TransactionExtraData[code=$code, location=$location]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.code != null) {
      json[r'code'] = this.code;
    } else {
      json[r'code'] = null;
    }
    if (this.location != null) {
      json[r'location'] = this.location;
    } else {
      json[r'location'] = null;
    }
    return json;
  }

  /// Returns a new [TransactionExtraData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TransactionExtraData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return TransactionExtraData(
        code: mapValueOfType<String>(json, r'code'),
        location: TransactionLocation.fromJson(json[r'location']),
      );
    }
    return null;
  }

  static List<TransactionExtraData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TransactionExtraData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TransactionExtraData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TransactionExtraData> mapFromJson(dynamic json) {
    final map = <String, TransactionExtraData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TransactionExtraData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TransactionExtraData-objects as value to a dart map
  static Map<String, List<TransactionExtraData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TransactionExtraData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TransactionExtraData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

