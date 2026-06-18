//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PlaidWebhookControllerMigrateWebhookUrlsRequest {
  /// Returns a new [PlaidWebhookControllerMigrateWebhookUrlsRequest] instance.
  PlaidWebhookControllerMigrateWebhookUrlsRequest({
    required this.baseUrl,
  });

  String baseUrl;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PlaidWebhookControllerMigrateWebhookUrlsRequest &&
    other.baseUrl == baseUrl;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (baseUrl.hashCode);

  @override
  String toString() => 'PlaidWebhookControllerMigrateWebhookUrlsRequest[baseUrl=$baseUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'baseUrl'] = this.baseUrl;
    return json;
  }

  /// Returns a new [PlaidWebhookControllerMigrateWebhookUrlsRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PlaidWebhookControllerMigrateWebhookUrlsRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'baseUrl'), 'Required key "PlaidWebhookControllerMigrateWebhookUrlsRequest[baseUrl]" is missing from JSON.');
        assert(json[r'baseUrl'] != null, 'Required key "PlaidWebhookControllerMigrateWebhookUrlsRequest[baseUrl]" has a null value in JSON.');
        return true;
      }());

      return PlaidWebhookControllerMigrateWebhookUrlsRequest(
        baseUrl: mapValueOfType<String>(json, r'baseUrl')!,
      );
    }
    return null;
  }

  static List<PlaidWebhookControllerMigrateWebhookUrlsRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PlaidWebhookControllerMigrateWebhookUrlsRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PlaidWebhookControllerMigrateWebhookUrlsRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PlaidWebhookControllerMigrateWebhookUrlsRequest> mapFromJson(dynamic json) {
    final map = <String, PlaidWebhookControllerMigrateWebhookUrlsRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PlaidWebhookControllerMigrateWebhookUrlsRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PlaidWebhookControllerMigrateWebhookUrlsRequest-objects as value to a dart map
  static Map<String, List<PlaidWebhookControllerMigrateWebhookUrlsRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PlaidWebhookControllerMigrateWebhookUrlsRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PlaidWebhookControllerMigrateWebhookUrlsRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'baseUrl',
  };
}

