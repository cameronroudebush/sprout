//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TotalTransactions {
  /// Returns a new [TotalTransactions] instance.
  TotalTransactions({
    required this.total,
  });

  num total;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TotalTransactions &&
    other.total == total;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (total.hashCode);

  @override
  String toString() => 'TotalTransactions[total=$total]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'total'] = this.total;
    return json;
  }

  /// Returns a new [TotalTransactions] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TotalTransactions? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TotalTransactions[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TotalTransactions[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return TotalTransactions(
        total: num.parse('${json[r'total']}'),
      );
    }
    return null;
  }

  static List<TotalTransactions> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TotalTransactions>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TotalTransactions.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TotalTransactions> mapFromJson(dynamic json) {
    final map = <String, TotalTransactions>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TotalTransactions.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TotalTransactions-objects as value to a dart map
  static Map<String, List<TotalTransactions>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TotalTransactions>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TotalTransactions.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'total',
  };
}

