//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Category {
  /// Returns a new [Category] instance.
  Category({
    required this.id,
    required this.name,
    this.parentCategoryId,
    this.icon,
    this.excludeFromCashFlow = false,
    this.canBeHighestExpense = true,
  });

  String id;

  /// The name of the category
  String name;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? parentCategoryId;

  /// The icon to use for this category. If one is not given, we'll use the default.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? icon;

  /// If we should exclude this category from cash flow calculations
  bool excludeFromCashFlow;

  /// If this category can be considered a \"high expense\" when calculating cash flow stats. You'd want to turn this off for things like credit card payments.
  bool canBeHighestExpense;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Category &&
    other.id == id &&
    other.name == name &&
    other.parentCategoryId == parentCategoryId &&
    other.icon == icon &&
    other.excludeFromCashFlow == excludeFromCashFlow &&
    other.canBeHighestExpense == canBeHighestExpense;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (parentCategoryId == null ? 0 : parentCategoryId!.hashCode) +
    (icon == null ? 0 : icon!.hashCode) +
    (excludeFromCashFlow.hashCode) +
    (canBeHighestExpense.hashCode);

  @override
  String toString() => 'Category[id=$id, name=$name, parentCategoryId=$parentCategoryId, icon=$icon, excludeFromCashFlow=$excludeFromCashFlow, canBeHighestExpense=$canBeHighestExpense]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
    if (this.parentCategoryId != null) {
      json[r'parentCategoryId'] = this.parentCategoryId;
    } else {
      json[r'parentCategoryId'] = null;
    }
    if (this.icon != null) {
      json[r'icon'] = this.icon;
    } else {
      json[r'icon'] = null;
    }
      json[r'excludeFromCashFlow'] = this.excludeFromCashFlow;
      json[r'canBeHighestExpense'] = this.canBeHighestExpense;
    return json;
  }

  /// Returns a new [Category] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Category? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Category[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Category[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "Category[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "Category[name]" has a null value in JSON.');
        assert(json.containsKey(r'excludeFromCashFlow'), 'Required key "Category[excludeFromCashFlow]" is missing from JSON.');
        assert(json[r'excludeFromCashFlow'] != null, 'Required key "Category[excludeFromCashFlow]" has a null value in JSON.');
        assert(json.containsKey(r'canBeHighestExpense'), 'Required key "Category[canBeHighestExpense]" is missing from JSON.');
        assert(json[r'canBeHighestExpense'] != null, 'Required key "Category[canBeHighestExpense]" has a null value in JSON.');
        return true;
      }());

      return Category(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        parentCategoryId: mapValueOfType<String>(json, r'parentCategoryId'),
        icon: mapValueOfType<String>(json, r'icon'),
        excludeFromCashFlow: mapValueOfType<bool>(json, r'excludeFromCashFlow')!,
        canBeHighestExpense: mapValueOfType<bool>(json, r'canBeHighestExpense')!,
      );
    }
    return null;
  }

  static List<Category> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Category>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Category.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Category> mapFromJson(dynamic json) {
    final map = <String, Category>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Category.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Category-objects as value to a dart map
  static Map<String, List<Category>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Category>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Category.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'excludeFromCashFlow',
    'canBeHighestExpense',
  };
}

