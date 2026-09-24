//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CategoryBudgetOverviewItem {
  /// Returns a new [CategoryBudgetOverviewItem] instance.
  CategoryBudgetOverviewItem({
    this.budgetId,
    required this.category,
    required this.budgetedAmount,
    required this.actualSpent,
    required this.remaining,
    required this.percentageUsed,
    required this.isOverBudget,
  });

  /// The ID of the budget, if configured for this category.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? budgetId;

  /// The category for this budget line item.
  Category category;

  /// The target budgeted amount for the month.
  num budgetedAmount;

  /// The actual spent amount for the month.
  num actualSpent;

  /// The remaining budget amount for the month (budgetedAmount - actualSpent).
  num remaining;

  /// The percentage of budget used (0 to 100+).
  num percentageUsed;

  /// Indicates whether actual spending exceeded the budget target for this category.
  bool isOverBudget;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CategoryBudgetOverviewItem &&
    other.budgetId == budgetId &&
    other.category == category &&
    other.budgetedAmount == budgetedAmount &&
    other.actualSpent == actualSpent &&
    other.remaining == remaining &&
    other.percentageUsed == percentageUsed &&
    other.isOverBudget == isOverBudget;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (budgetId == null ? 0 : budgetId!.hashCode) +
    (category.hashCode) +
    (budgetedAmount.hashCode) +
    (actualSpent.hashCode) +
    (remaining.hashCode) +
    (percentageUsed.hashCode) +
    (isOverBudget.hashCode);

  @override
  String toString() => 'CategoryBudgetOverviewItem[budgetId=$budgetId, category=$category, budgetedAmount=$budgetedAmount, actualSpent=$actualSpent, remaining=$remaining, percentageUsed=$percentageUsed, isOverBudget=$isOverBudget]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.budgetId != null) {
      json[r'budgetId'] = this.budgetId;
    } else {
      json[r'budgetId'] = null;
    }
      json[r'category'] = this.category;
      json[r'budgetedAmount'] = this.budgetedAmount;
      json[r'actualSpent'] = this.actualSpent;
      json[r'remaining'] = this.remaining;
      json[r'percentageUsed'] = this.percentageUsed;
      json[r'isOverBudget'] = this.isOverBudget;
    return json;
  }

  /// Returns a new [CategoryBudgetOverviewItem] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CategoryBudgetOverviewItem? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'category'), 'Required key "CategoryBudgetOverviewItem[category]" is missing from JSON.');
        assert(json[r'category'] != null, 'Required key "CategoryBudgetOverviewItem[category]" has a null value in JSON.');
        assert(json.containsKey(r'budgetedAmount'), 'Required key "CategoryBudgetOverviewItem[budgetedAmount]" is missing from JSON.');
        assert(json[r'budgetedAmount'] != null, 'Required key "CategoryBudgetOverviewItem[budgetedAmount]" has a null value in JSON.');
        assert(json.containsKey(r'actualSpent'), 'Required key "CategoryBudgetOverviewItem[actualSpent]" is missing from JSON.');
        assert(json[r'actualSpent'] != null, 'Required key "CategoryBudgetOverviewItem[actualSpent]" has a null value in JSON.');
        assert(json.containsKey(r'remaining'), 'Required key "CategoryBudgetOverviewItem[remaining]" is missing from JSON.');
        assert(json[r'remaining'] != null, 'Required key "CategoryBudgetOverviewItem[remaining]" has a null value in JSON.');
        assert(json.containsKey(r'percentageUsed'), 'Required key "CategoryBudgetOverviewItem[percentageUsed]" is missing from JSON.');
        assert(json[r'percentageUsed'] != null, 'Required key "CategoryBudgetOverviewItem[percentageUsed]" has a null value in JSON.');
        assert(json.containsKey(r'isOverBudget'), 'Required key "CategoryBudgetOverviewItem[isOverBudget]" is missing from JSON.');
        assert(json[r'isOverBudget'] != null, 'Required key "CategoryBudgetOverviewItem[isOverBudget]" has a null value in JSON.');
        return true;
      }());

      return CategoryBudgetOverviewItem(
        budgetId: mapValueOfType<String>(json, r'budgetId'),
        category: Category.fromJson(json[r'category'])!,
        budgetedAmount: num.parse('${json[r'budgetedAmount']}'),
        actualSpent: num.parse('${json[r'actualSpent']}'),
        remaining: num.parse('${json[r'remaining']}'),
        percentageUsed: num.parse('${json[r'percentageUsed']}'),
        isOverBudget: mapValueOfType<bool>(json, r'isOverBudget')!,
      );
    }
    return null;
  }

  static List<CategoryBudgetOverviewItem> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CategoryBudgetOverviewItem>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CategoryBudgetOverviewItem.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CategoryBudgetOverviewItem> mapFromJson(dynamic json) {
    final map = <String, CategoryBudgetOverviewItem>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CategoryBudgetOverviewItem.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CategoryBudgetOverviewItem-objects as value to a dart map
  static Map<String, List<CategoryBudgetOverviewItem>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CategoryBudgetOverviewItem>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CategoryBudgetOverviewItem.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'category',
    'budgetedAmount',
    'actualSpent',
    'remaining',
    'percentageUsed',
    'isOverBudget',
  };
}

