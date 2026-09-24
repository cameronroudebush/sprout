//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class BudgetOverviewResponseDto {
  /// Returns a new [BudgetOverviewResponseDto] instance.
  BudgetOverviewResponseDto({
    required this.year,
    required this.month,
    required this.totalBudgeted,
    required this.totalSpent,
    required this.totalRemaining,
    required this.isOverBudget,
    required this.totalOverBudgetAmount,
    this.items = const [],
  });

  /// The year of this budget overview.
  num year;

  /// The month of this budget overview (1-12).
  num month;

  /// Total budgeted amount across all categories for the month.
  num totalBudgeted;

  /// Total actual spent amount across budgeted categories for the month.
  num totalSpent;

  /// Total remaining budget amount across all categories.
  num totalRemaining;

  /// Indicates whether total spending across budgeted categories exceeded the total budget limit.
  bool isOverBudget;

  /// Total amount by which spending exceeded budget limits.
  num totalOverBudgetAmount;

  /// List of category budget overview items.
  List<CategoryBudgetOverviewItem> items;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BudgetOverviewResponseDto &&
    other.year == year &&
    other.month == month &&
    other.totalBudgeted == totalBudgeted &&
    other.totalSpent == totalSpent &&
    other.totalRemaining == totalRemaining &&
    other.isOverBudget == isOverBudget &&
    other.totalOverBudgetAmount == totalOverBudgetAmount &&
    _deepEquality.equals(other.items, items);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (year.hashCode) +
    (month.hashCode) +
    (totalBudgeted.hashCode) +
    (totalSpent.hashCode) +
    (totalRemaining.hashCode) +
    (isOverBudget.hashCode) +
    (totalOverBudgetAmount.hashCode) +
    (items.hashCode);

  @override
  String toString() => 'BudgetOverviewResponseDto[year=$year, month=$month, totalBudgeted=$totalBudgeted, totalSpent=$totalSpent, totalRemaining=$totalRemaining, isOverBudget=$isOverBudget, totalOverBudgetAmount=$totalOverBudgetAmount, items=$items]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'year'] = this.year;
      json[r'month'] = this.month;
      json[r'totalBudgeted'] = this.totalBudgeted;
      json[r'totalSpent'] = this.totalSpent;
      json[r'totalRemaining'] = this.totalRemaining;
      json[r'isOverBudget'] = this.isOverBudget;
      json[r'totalOverBudgetAmount'] = this.totalOverBudgetAmount;
      json[r'items'] = this.items;
    return json;
  }

  /// Returns a new [BudgetOverviewResponseDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BudgetOverviewResponseDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'year'), 'Required key "BudgetOverviewResponseDto[year]" is missing from JSON.');
        assert(json[r'year'] != null, 'Required key "BudgetOverviewResponseDto[year]" has a null value in JSON.');
        assert(json.containsKey(r'month'), 'Required key "BudgetOverviewResponseDto[month]" is missing from JSON.');
        assert(json[r'month'] != null, 'Required key "BudgetOverviewResponseDto[month]" has a null value in JSON.');
        assert(json.containsKey(r'totalBudgeted'), 'Required key "BudgetOverviewResponseDto[totalBudgeted]" is missing from JSON.');
        assert(json[r'totalBudgeted'] != null, 'Required key "BudgetOverviewResponseDto[totalBudgeted]" has a null value in JSON.');
        assert(json.containsKey(r'totalSpent'), 'Required key "BudgetOverviewResponseDto[totalSpent]" is missing from JSON.');
        assert(json[r'totalSpent'] != null, 'Required key "BudgetOverviewResponseDto[totalSpent]" has a null value in JSON.');
        assert(json.containsKey(r'totalRemaining'), 'Required key "BudgetOverviewResponseDto[totalRemaining]" is missing from JSON.');
        assert(json[r'totalRemaining'] != null, 'Required key "BudgetOverviewResponseDto[totalRemaining]" has a null value in JSON.');
        assert(json.containsKey(r'isOverBudget'), 'Required key "BudgetOverviewResponseDto[isOverBudget]" is missing from JSON.');
        assert(json[r'isOverBudget'] != null, 'Required key "BudgetOverviewResponseDto[isOverBudget]" has a null value in JSON.');
        assert(json.containsKey(r'totalOverBudgetAmount'), 'Required key "BudgetOverviewResponseDto[totalOverBudgetAmount]" is missing from JSON.');
        assert(json[r'totalOverBudgetAmount'] != null, 'Required key "BudgetOverviewResponseDto[totalOverBudgetAmount]" has a null value in JSON.');
        assert(json.containsKey(r'items'), 'Required key "BudgetOverviewResponseDto[items]" is missing from JSON.');
        assert(json[r'items'] != null, 'Required key "BudgetOverviewResponseDto[items]" has a null value in JSON.');
        return true;
      }());

      return BudgetOverviewResponseDto(
        year: num.parse('${json[r'year']}'),
        month: num.parse('${json[r'month']}'),
        totalBudgeted: num.parse('${json[r'totalBudgeted']}'),
        totalSpent: num.parse('${json[r'totalSpent']}'),
        totalRemaining: num.parse('${json[r'totalRemaining']}'),
        isOverBudget: mapValueOfType<bool>(json, r'isOverBudget')!,
        totalOverBudgetAmount: num.parse('${json[r'totalOverBudgetAmount']}'),
        items: CategoryBudgetOverviewItem.listFromJson(json[r'items']),
      );
    }
    return null;
  }

  static List<BudgetOverviewResponseDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BudgetOverviewResponseDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BudgetOverviewResponseDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BudgetOverviewResponseDto> mapFromJson(dynamic json) {
    final map = <String, BudgetOverviewResponseDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BudgetOverviewResponseDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BudgetOverviewResponseDto-objects as value to a dart map
  static Map<String, List<BudgetOverviewResponseDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BudgetOverviewResponseDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BudgetOverviewResponseDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'year',
    'month',
    'totalBudgeted',
    'totalSpent',
    'totalRemaining',
    'isOverBudget',
    'totalOverBudgetAmount',
    'items',
  };
}

