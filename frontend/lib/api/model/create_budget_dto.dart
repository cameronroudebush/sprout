//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateBudgetDto {
  /// Returns a new [CreateBudgetDto] instance.
  CreateBudgetDto({
    required this.categoryId,
    required this.amount,
  });

  /// The ID of the category for this budget.
  String categoryId;

  /// The target monthly budget amount.
  ///
  /// Minimum value: 0
  num amount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateBudgetDto &&
    other.categoryId == categoryId &&
    other.amount == amount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (categoryId.hashCode) +
    (amount.hashCode);

  @override
  String toString() => 'CreateBudgetDto[categoryId=$categoryId, amount=$amount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'categoryId'] = this.categoryId;
      json[r'amount'] = this.amount;
    return json;
  }

  /// Returns a new [CreateBudgetDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateBudgetDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'categoryId'), 'Required key "CreateBudgetDto[categoryId]" is missing from JSON.');
        assert(json[r'categoryId'] != null, 'Required key "CreateBudgetDto[categoryId]" has a null value in JSON.');
        assert(json.containsKey(r'amount'), 'Required key "CreateBudgetDto[amount]" is missing from JSON.');
        assert(json[r'amount'] != null, 'Required key "CreateBudgetDto[amount]" has a null value in JSON.');
        return true;
      }());

      return CreateBudgetDto(
        categoryId: mapValueOfType<String>(json, r'categoryId')!,
        amount: num.parse('${json[r'amount']}'),
      );
    }
    return null;
  }

  static List<CreateBudgetDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateBudgetDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateBudgetDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateBudgetDto> mapFromJson(dynamic json) {
    final map = <String, CreateBudgetDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateBudgetDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateBudgetDto-objects as value to a dart map
  static Map<String, List<CreateBudgetDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateBudgetDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateBudgetDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'categoryId',
    'amount',
  };
}
