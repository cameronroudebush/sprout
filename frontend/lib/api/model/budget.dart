//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Budget {
  /// Returns a new [Budget] instance.
  Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
  });

  String id;

  /// The ID of the category for this budget.
  String categoryId;

  /// The numeric value converted to the user's preferred currency format. This overrides the original amount property.
  ///
  /// Minimum value: 0
  num amount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Budget &&
    other.id == id &&
    other.categoryId == categoryId &&
    other.amount == amount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (categoryId.hashCode) +
    (amount.hashCode);

  @override
  String toString() => 'Budget[id=$id, categoryId=$categoryId, amount=$amount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'categoryId'] = this.categoryId;
      json[r'amount'] = this.amount;
    return json;
  }

  /// Returns a new [Budget] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Budget? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Budget[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Budget[id]" has a null value in JSON.');
        assert(json.containsKey(r'categoryId'), 'Required key "Budget[categoryId]" is missing from JSON.');
        assert(json[r'categoryId'] != null, 'Required key "Budget[categoryId]" has a null value in JSON.');
        assert(json.containsKey(r'amount'), 'Required key "Budget[amount]" is missing from JSON.');
        assert(json[r'amount'] != null, 'Required key "Budget[amount]" has a null value in JSON.');
        return true;
      }());

      return Budget(
        id: mapValueOfType<String>(json, r'id')!,
        categoryId: mapValueOfType<String>(json, r'categoryId')!,
        amount: num.parse('${json[r'amount']}'),
      );
    }
    return null;
  }

  static List<Budget> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Budget>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Budget.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Budget> mapFromJson(dynamic json) {
    final map = <String, Budget>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Budget.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Budget-objects as value to a dart map
  static Map<String, List<Budget>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Budget>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Budget.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'categoryId',
    'amount',
  };
}

