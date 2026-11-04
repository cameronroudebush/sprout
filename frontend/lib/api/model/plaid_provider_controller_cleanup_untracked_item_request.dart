//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PlaidProviderControllerCleanupUntrackedItemRequest {
  /// Returns a new [PlaidProviderControllerCleanupUntrackedItemRequest] instance.
  PlaidProviderControllerCleanupUntrackedItemRequest({
    required this.accessToken,
  });

  String accessToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaidProviderControllerCleanupUntrackedItemRequest &&
          other.accessToken == accessToken;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (accessToken.hashCode);

  @override
  String toString() =>
      'PlaidProviderControllerCleanupUntrackedItemRequest[accessToken=$accessToken]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'accessToken'] = this.accessToken;
    return json;
  }

  /// Returns a new [PlaidProviderControllerCleanupUntrackedItemRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PlaidProviderControllerCleanupUntrackedItemRequest? fromJson(
      dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'accessToken'),
            'Required key "PlaidProviderControllerCleanupUntrackedItemRequest[accessToken]" is missing from JSON.');
        assert(json[r'accessToken'] != null,
            'Required key "PlaidProviderControllerCleanupUntrackedItemRequest[accessToken]" has a null value in JSON.');
        return true;
      }());

      return PlaidProviderControllerCleanupUntrackedItemRequest(
        accessToken: mapValueOfType<String>(json, r'accessToken')!,
      );
    }
    return null;
  }

  static List<PlaidProviderControllerCleanupUntrackedItemRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <PlaidProviderControllerCleanupUntrackedItemRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value =
            PlaidProviderControllerCleanupUntrackedItemRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PlaidProviderControllerCleanupUntrackedItemRequest>
      mapFromJson(dynamic json) {
    final map = <String, PlaidProviderControllerCleanupUntrackedItemRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value =
            PlaidProviderControllerCleanupUntrackedItemRequest.fromJson(
                entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PlaidProviderControllerCleanupUntrackedItemRequest-objects as value to a dart map
  static Map<String, List<PlaidProviderControllerCleanupUntrackedItemRequest>>
      mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map =
        <String, List<PlaidProviderControllerCleanupUntrackedItemRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] =
            PlaidProviderControllerCleanupUntrackedItemRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'accessToken',
  };
}
