//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MonthlyCategoryData {
  /// Returns a new [MonthlyCategoryData] instance.
  MonthlyCategoryData({
    required this.name,
    required this.amount,
    required this.color,
  });

  /// Name of the category
  String name;

  /// Total amount spent in this category for this month
  num amount;

  /// Color for the category. Will be a hex code.
  String color;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MonthlyCategoryData &&
    other.name == name &&
    other.amount == amount &&
    other.color == color;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (amount.hashCode) +
    (color.hashCode);

  @override
  String toString() => 'MonthlyCategoryData[name=$name, amount=$amount, color=$color]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'amount'] = this.amount;
      json[r'color'] = this.color;
    return json;
  }

  /// Returns a new [MonthlyCategoryData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MonthlyCategoryData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MonthlyCategoryData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MonthlyCategoryData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MonthlyCategoryData(
        name: mapValueOfType<String>(json, r'name')!,
        amount: num.parse('${json[r'amount']}'),
        color: mapValueOfType<String>(json, r'color')!,
      );
    }
    return null;
  }

  static List<MonthlyCategoryData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MonthlyCategoryData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MonthlyCategoryData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MonthlyCategoryData> mapFromJson(dynamic json) {
    final map = <String, MonthlyCategoryData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MonthlyCategoryData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MonthlyCategoryData-objects as value to a dart map
  static Map<String, List<MonthlyCategoryData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MonthlyCategoryData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MonthlyCategoryData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'amount',
    'color',
  };
}

