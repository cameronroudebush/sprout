//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DailySpendingItem {
  /// Returns a new [DailySpendingItem] instance.
  DailySpendingItem({
    required this.day,
    required this.amount,
  });

  /// The day of the month (1-31).
  num day;

  /// The total spending amount for this specific day.
  num amount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DailySpendingItem &&
    other.day == day &&
    other.amount == amount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (day.hashCode) +
    (amount.hashCode);

  @override
  String toString() => 'DailySpendingItem[day=$day, amount=$amount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'day'] = this.day;
      json[r'amount'] = this.amount;
    return json;
  }

  /// Returns a new [DailySpendingItem] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DailySpendingItem? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'day'), 'Required key "DailySpendingItem[day]" is missing from JSON.');
        assert(json[r'day'] != null, 'Required key "DailySpendingItem[day]" has a null value in JSON.');
        assert(json.containsKey(r'amount'), 'Required key "DailySpendingItem[amount]" is missing from JSON.');
        assert(json[r'amount'] != null, 'Required key "DailySpendingItem[amount]" has a null value in JSON.');
        return true;
      }());

      return DailySpendingItem(
        day: num.parse('${json[r'day']}'),
        amount: num.parse('${json[r'amount']}'),
      );
    }
    return null;
  }

  static List<DailySpendingItem> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DailySpendingItem>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DailySpendingItem.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DailySpendingItem> mapFromJson(dynamic json) {
    final map = <String, DailySpendingItem>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DailySpendingItem.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DailySpendingItem-objects as value to a dart map
  static Map<String, List<DailySpendingItem>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DailySpendingItem>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DailySpendingItem.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'day',
    'amount',
  };
}

