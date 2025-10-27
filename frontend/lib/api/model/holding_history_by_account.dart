//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class HoldingHistoryByAccount {
  /// Returns a new [HoldingHistoryByAccount] instance.
  HoldingHistoryByAccount({
    this.history = const {},
  });

  Map<String, List<EntityHistory>> history;

  @override
  bool operator ==(Object other) => identical(this, other) || other is HoldingHistoryByAccount &&
    _deepEquality.equals(other.history, history);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (history.hashCode);

  @override
  String toString() => 'HoldingHistoryByAccount[history=$history]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'history'] = this.history;
    return json;
  }

  /// Returns a new [HoldingHistoryByAccount] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static HoldingHistoryByAccount? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "HoldingHistoryByAccount[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "HoldingHistoryByAccount[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return HoldingHistoryByAccount(
        history: json[r'history'] == null
          ? const {}
            : EntityHistory.mapListFromJson(json[r'history']),
      );
    }
    return null;
  }

  static List<HoldingHistoryByAccount> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <HoldingHistoryByAccount>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = HoldingHistoryByAccount.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, HoldingHistoryByAccount> mapFromJson(dynamic json) {
    final map = <String, HoldingHistoryByAccount>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = HoldingHistoryByAccount.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of HoldingHistoryByAccount-objects as value to a dart map
  static Map<String, List<HoldingHistoryByAccount>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<HoldingHistoryByAccount>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = HoldingHistoryByAccount.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'history',
  };
}

