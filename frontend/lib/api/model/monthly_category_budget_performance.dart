//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MonthlyCategoryBudgetPerformance {
  /// Returns a new [MonthlyCategoryBudgetPerformance] instance.
  MonthlyCategoryBudgetPerformance({
    required this.year,
    required this.month,
    required this.budgetedAmount,
    required this.actualSpent,
    required this.remaining,
    required this.isOverBudget,
  });

  /// Year of performance snapshot.
  num year;

  /// Month of performance snapshot (1-12).
  num month;

  /// Target budgeted amount.
  num budgetedAmount;

  /// Actual spent amount.
  num actualSpent;

  /// Remaining amount.
  num remaining;

  /// Indicates whether actual spending exceeded the target budget.
  bool isOverBudget;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MonthlyCategoryBudgetPerformance &&
    other.year == year &&
    other.month == month &&
    other.budgetedAmount == budgetedAmount &&
    other.actualSpent == actualSpent &&
    other.remaining == remaining &&
    other.isOverBudget == isOverBudget;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (year.hashCode) +
    (month.hashCode) +
    (budgetedAmount.hashCode) +
    (actualSpent.hashCode) +
    (remaining.hashCode) +
    (isOverBudget.hashCode);

  @override
  String toString() => 'MonthlyCategoryBudgetPerformance[year=$year, month=$month, budgetedAmount=$budgetedAmount, actualSpent=$actualSpent, remaining=$remaining, isOverBudget=$isOverBudget]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'year'] = this.year;
      json[r'month'] = this.month;
      json[r'budgetedAmount'] = this.budgetedAmount;
      json[r'actualSpent'] = this.actualSpent;
      json[r'remaining'] = this.remaining;
      json[r'isOverBudget'] = this.isOverBudget;
    return json;
  }

  /// Returns a new [MonthlyCategoryBudgetPerformance] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MonthlyCategoryBudgetPerformance? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'year'), 'Required key "MonthlyCategoryBudgetPerformance[year]" is missing from JSON.');
        assert(json[r'year'] != null, 'Required key "MonthlyCategoryBudgetPerformance[year]" has a null value in JSON.');
        assert(json.containsKey(r'month'), 'Required key "MonthlyCategoryBudgetPerformance[month]" is missing from JSON.');
        assert(json[r'month'] != null, 'Required key "MonthlyCategoryBudgetPerformance[month]" has a null value in JSON.');
        assert(json.containsKey(r'budgetedAmount'), 'Required key "MonthlyCategoryBudgetPerformance[budgetedAmount]" is missing from JSON.');
        assert(json[r'budgetedAmount'] != null, 'Required key "MonthlyCategoryBudgetPerformance[budgetedAmount]" has a null value in JSON.');
        assert(json.containsKey(r'actualSpent'), 'Required key "MonthlyCategoryBudgetPerformance[actualSpent]" is missing from JSON.');
        assert(json[r'actualSpent'] != null, 'Required key "MonthlyCategoryBudgetPerformance[actualSpent]" has a null value in JSON.');
        assert(json.containsKey(r'remaining'), 'Required key "MonthlyCategoryBudgetPerformance[remaining]" is missing from JSON.');
        assert(json[r'remaining'] != null, 'Required key "MonthlyCategoryBudgetPerformance[remaining]" has a null value in JSON.');
        assert(json.containsKey(r'isOverBudget'), 'Required key "MonthlyCategoryBudgetPerformance[isOverBudget]" is missing from JSON.');
        assert(json[r'isOverBudget'] != null, 'Required key "MonthlyCategoryBudgetPerformance[isOverBudget]" has a null value in JSON.');
        return true;
      }());

      return MonthlyCategoryBudgetPerformance(
        year: num.parse('${json[r'year']}'),
        month: num.parse('${json[r'month']}'),
        budgetedAmount: num.parse('${json[r'budgetedAmount']}'),
        actualSpent: num.parse('${json[r'actualSpent']}'),
        remaining: num.parse('${json[r'remaining']}'),
        isOverBudget: mapValueOfType<bool>(json, r'isOverBudget')!,
      );
    }
    return null;
  }

  static List<MonthlyCategoryBudgetPerformance> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MonthlyCategoryBudgetPerformance>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MonthlyCategoryBudgetPerformance.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MonthlyCategoryBudgetPerformance> mapFromJson(dynamic json) {
    final map = <String, MonthlyCategoryBudgetPerformance>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MonthlyCategoryBudgetPerformance.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MonthlyCategoryBudgetPerformance-objects as value to a dart map
  static Map<String, List<MonthlyCategoryBudgetPerformance>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MonthlyCategoryBudgetPerformance>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MonthlyCategoryBudgetPerformance.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'year',
    'month',
    'budgetedAmount',
    'actualSpent',
    'remaining',
    'isOverBudget',
  };
}

