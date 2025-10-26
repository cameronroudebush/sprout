//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CashFlowStats {
  /// Returns a new [CashFlowStats] instance.
  CashFlowStats({
    required this.totalExpense,
    required this.totalIncome,
    required this.count,
    this.largestExpense,
  });

  num totalExpense;

  num totalIncome;

  /// How many total transactions we have for this query
  num count;

  /// The largest expense we had for this time period
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Transaction? largestExpense;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CashFlowStats &&
    other.totalExpense == totalExpense &&
    other.totalIncome == totalIncome &&
    other.count == count &&
    other.largestExpense == largestExpense;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (totalExpense.hashCode) +
    (totalIncome.hashCode) +
    (count.hashCode) +
    (largestExpense == null ? 0 : largestExpense!.hashCode);

  @override
  String toString() => 'CashFlowStats[totalExpense=$totalExpense, totalIncome=$totalIncome, count=$count, largestExpense=$largestExpense]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'totalExpense'] = this.totalExpense;
      json[r'totalIncome'] = this.totalIncome;
      json[r'count'] = this.count;
    if (this.largestExpense != null) {
      json[r'largestExpense'] = this.largestExpense;
    } else {
      json[r'largestExpense'] = null;
    }
    return json;
  }

  /// Returns a new [CashFlowStats] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CashFlowStats? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CashFlowStats[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CashFlowStats[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CashFlowStats(
        totalExpense: num.parse('${json[r'totalExpense']}'),
        totalIncome: num.parse('${json[r'totalIncome']}'),
        count: num.parse('${json[r'count']}'),
        largestExpense: Transaction.fromJson(json[r'largestExpense']),
      );
    }
    return null;
  }

  static List<CashFlowStats> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CashFlowStats>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CashFlowStats.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CashFlowStats> mapFromJson(dynamic json) {
    final map = <String, CashFlowStats>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CashFlowStats.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CashFlowStats-objects as value to a dart map
  static Map<String, List<CashFlowStats>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CashFlowStats>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CashFlowStats.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'totalExpense',
    'totalIncome',
    'count',
  };
}

