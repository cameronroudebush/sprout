//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateBudgetDto {
  /// Returns a new [UpdateBudgetDto] instance.
  UpdateBudgetDto({
    required this.amount,
  });

  /// The updated target monthly budget amount.
  ///
  /// Minimum value: 0
  num amount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateBudgetDto &&
    other.amount == amount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (amount.hashCode);

  @override
  String toString() => 'UpdateBudgetDto[amount=$amount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'amount'] = this.amount;
    return json;
  }

  /// Returns a new [UpdateBudgetDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateBudgetDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'amount'), 'Required key "UpdateBudgetDto[amount]" is missing from JSON.');
        assert(json[r'amount'] != null, 'Required key "UpdateBudgetDto[amount]" has a null value in JSON.');
        return true;
      }());

      return UpdateBudgetDto(
        amount: num.parse('${json[r'amount']}'),
      );
    }
    return null;
  }

  static List<UpdateBudgetDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateBudgetDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateBudgetDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateBudgetDto> mapFromJson(dynamic json) {
    final map = <String, UpdateBudgetDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateBudgetDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateBudgetDto-objects as value to a dart map
  static Map<String, List<UpdateBudgetDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateBudgetDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateBudgetDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'amount',
  };
}
