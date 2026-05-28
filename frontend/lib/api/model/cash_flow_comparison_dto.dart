//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CashFlowComparisonDTO {
  /// Returns a new [CashFlowComparisonDTO] instance.
  CashFlowComparisonDTO({
    this.currentMonthData = const [],
    this.targetMonthData = const [],
    required this.currentMonthLabel,
    required this.targetMonthLabel,
  });

  /// Daily cumulative spending for the current month
  List<HistoricalDataPoint> currentMonthData;

  /// Daily cumulative spending for the target comparison month
  List<HistoricalDataPoint> targetMonthData;

  /// Label for the current month (e.g., 'May 2026')
  String currentMonthLabel;

  /// Label for the target comparison month (e.g., 'Apr 2026')
  String targetMonthLabel;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CashFlowComparisonDTO &&
    _deepEquality.equals(other.currentMonthData, currentMonthData) &&
    _deepEquality.equals(other.targetMonthData, targetMonthData) &&
    other.currentMonthLabel == currentMonthLabel &&
    other.targetMonthLabel == targetMonthLabel;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (currentMonthData.hashCode) +
    (targetMonthData.hashCode) +
    (currentMonthLabel.hashCode) +
    (targetMonthLabel.hashCode);

  @override
  String toString() => 'CashFlowComparisonDTO[currentMonthData=$currentMonthData, targetMonthData=$targetMonthData, currentMonthLabel=$currentMonthLabel, targetMonthLabel=$targetMonthLabel]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'currentMonthData'] = this.currentMonthData;
      json[r'targetMonthData'] = this.targetMonthData;
      json[r'currentMonthLabel'] = this.currentMonthLabel;
      json[r'targetMonthLabel'] = this.targetMonthLabel;
    return json;
  }

  /// Returns a new [CashFlowComparisonDTO] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CashFlowComparisonDTO? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'currentMonthData'), 'Required key "CashFlowComparisonDTO[currentMonthData]" is missing from JSON.');
        assert(json[r'currentMonthData'] != null, 'Required key "CashFlowComparisonDTO[currentMonthData]" has a null value in JSON.');
        assert(json.containsKey(r'targetMonthData'), 'Required key "CashFlowComparisonDTO[targetMonthData]" is missing from JSON.');
        assert(json[r'targetMonthData'] != null, 'Required key "CashFlowComparisonDTO[targetMonthData]" has a null value in JSON.');
        assert(json.containsKey(r'currentMonthLabel'), 'Required key "CashFlowComparisonDTO[currentMonthLabel]" is missing from JSON.');
        assert(json[r'currentMonthLabel'] != null, 'Required key "CashFlowComparisonDTO[currentMonthLabel]" has a null value in JSON.');
        assert(json.containsKey(r'targetMonthLabel'), 'Required key "CashFlowComparisonDTO[targetMonthLabel]" is missing from JSON.');
        assert(json[r'targetMonthLabel'] != null, 'Required key "CashFlowComparisonDTO[targetMonthLabel]" has a null value in JSON.');
        return true;
      }());

      return CashFlowComparisonDTO(
        currentMonthData: HistoricalDataPoint.listFromJson(json[r'currentMonthData']),
        targetMonthData: HistoricalDataPoint.listFromJson(json[r'targetMonthData']),
        currentMonthLabel: mapValueOfType<String>(json, r'currentMonthLabel')!,
        targetMonthLabel: mapValueOfType<String>(json, r'targetMonthLabel')!,
      );
    }
    return null;
  }

  static List<CashFlowComparisonDTO> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CashFlowComparisonDTO>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CashFlowComparisonDTO.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CashFlowComparisonDTO> mapFromJson(dynamic json) {
    final map = <String, CashFlowComparisonDTO>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CashFlowComparisonDTO.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CashFlowComparisonDTO-objects as value to a dart map
  static Map<String, List<CashFlowComparisonDTO>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CashFlowComparisonDTO>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CashFlowComparisonDTO.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'currentMonthData',
    'targetMonthData',
    'currentMonthLabel',
    'targetMonthLabel',
  };
}

