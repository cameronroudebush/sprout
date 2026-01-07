//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MonthlySpendingStats {
  /// Returns a new [MonthlySpendingStats] instance.
  MonthlySpendingStats({
    this.categories = const [],
    required this.monthLabel,
    required this.date,
    required this.totalSpending,
    required this.periodAverage,
  });

  /// A breakdown of the top categories for the month based on the request
  List<MonthlyCategoryData> categories;

  /// Month label
  String monthLabel;

  /// The date, just used for sorting
  DateTime date;

  /// Total spending for the month
  num totalSpending;

  /// Average spending across the requested period (for the trend line)
  num periodAverage;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MonthlySpendingStats &&
    _deepEquality.equals(other.categories, categories) &&
    other.monthLabel == monthLabel &&
    other.date == date &&
    other.totalSpending == totalSpending &&
    other.periodAverage == periodAverage;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (categories.hashCode) +
    (monthLabel.hashCode) +
    (date.hashCode) +
    (totalSpending.hashCode) +
    (periodAverage.hashCode);

  @override
  String toString() => 'MonthlySpendingStats[categories=$categories, monthLabel=$monthLabel, date=$date, totalSpending=$totalSpending, periodAverage=$periodAverage]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'categories'] = this.categories;
      json[r'monthLabel'] = this.monthLabel;
      json[r'date'] = this.date.toUtc().toIso8601String();
      json[r'totalSpending'] = this.totalSpending;
      json[r'periodAverage'] = this.periodAverage;
    return json;
  }

  /// Returns a new [MonthlySpendingStats] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MonthlySpendingStats? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MonthlySpendingStats[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MonthlySpendingStats[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MonthlySpendingStats(
        categories: MonthlyCategoryData.listFromJson(json[r'categories']),
        monthLabel: mapValueOfType<String>(json, r'monthLabel')!,
        date: mapDateTime(json, r'date', r'')!,
        totalSpending: num.parse('${json[r'totalSpending']}'),
        periodAverage: num.parse('${json[r'periodAverage']}'),
      );
    }
    return null;
  }

  static List<MonthlySpendingStats> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MonthlySpendingStats>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MonthlySpendingStats.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MonthlySpendingStats> mapFromJson(dynamic json) {
    final map = <String, MonthlySpendingStats>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MonthlySpendingStats.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MonthlySpendingStats-objects as value to a dart map
  static Map<String, List<MonthlySpendingStats>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MonthlySpendingStats>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MonthlySpendingStats.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'categories',
    'monthLabel',
    'date',
    'totalSpending',
    'periodAverage',
  };
}

