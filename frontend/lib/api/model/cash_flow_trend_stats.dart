//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CashFlowTrendStats {
  /// Returns a new [CashFlowTrendStats] instance.
  CashFlowTrendStats({
    required this.label,
    required this.topValue,
    required this.bottomValue,
    required this.trendValue,
  });

  /// The label for the X-axis (e.g., 'Jan', 'Feb')
  String label;

  /// Total income for the month (top bar)
  num topValue;

  /// Total expense for the month as an absolute value (bottom bar)
  num bottomValue;

  /// Net cash flow (Income - Expense) for the trend line
  num trendValue;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CashFlowTrendStats &&
    other.label == label &&
    other.topValue == topValue &&
    other.bottomValue == bottomValue &&
    other.trendValue == trendValue;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (label.hashCode) +
    (topValue.hashCode) +
    (bottomValue.hashCode) +
    (trendValue.hashCode);

  @override
  String toString() => 'CashFlowTrendStats[label=$label, topValue=$topValue, bottomValue=$bottomValue, trendValue=$trendValue]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'label'] = this.label;
      json[r'topValue'] = this.topValue;
      json[r'bottomValue'] = this.bottomValue;
      json[r'trendValue'] = this.trendValue;
    return json;
  }

  /// Returns a new [CashFlowTrendStats] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CashFlowTrendStats? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'label'), 'Required key "CashFlowTrendStats[label]" is missing from JSON.');
        assert(json[r'label'] != null, 'Required key "CashFlowTrendStats[label]" has a null value in JSON.');
        assert(json.containsKey(r'topValue'), 'Required key "CashFlowTrendStats[topValue]" is missing from JSON.');
        assert(json[r'topValue'] != null, 'Required key "CashFlowTrendStats[topValue]" has a null value in JSON.');
        assert(json.containsKey(r'bottomValue'), 'Required key "CashFlowTrendStats[bottomValue]" is missing from JSON.');
        assert(json[r'bottomValue'] != null, 'Required key "CashFlowTrendStats[bottomValue]" has a null value in JSON.');
        assert(json.containsKey(r'trendValue'), 'Required key "CashFlowTrendStats[trendValue]" is missing from JSON.');
        assert(json[r'trendValue'] != null, 'Required key "CashFlowTrendStats[trendValue]" has a null value in JSON.');
        return true;
      }());

      return CashFlowTrendStats(
        label: mapValueOfType<String>(json, r'label')!,
        topValue: num.parse('${json[r'topValue']}'),
        bottomValue: num.parse('${json[r'bottomValue']}'),
        trendValue: num.parse('${json[r'trendValue']}'),
      );
    }
    return null;
  }

  static List<CashFlowTrendStats> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CashFlowTrendStats>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CashFlowTrendStats.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CashFlowTrendStats> mapFromJson(dynamic json) {
    final map = <String, CashFlowTrendStats>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CashFlowTrendStats.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CashFlowTrendStats-objects as value to a dart map
  static Map<String, List<CashFlowTrendStats>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CashFlowTrendStats>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CashFlowTrendStats.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'label',
    'topValue',
    'bottomValue',
    'trendValue',
  };
}

