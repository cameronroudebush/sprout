//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SSEData {
  /// Returns a new [SSEData] instance.
  SSEData({
    required this.event,
    this.payload,
  });

  SSEDataEventEnum event;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Object? payload;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SSEData &&
    other.event == event &&
    other.payload == payload;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (event.hashCode) +
    (payload == null ? 0 : payload!.hashCode);

  @override
  String toString() => 'SSEData[event=$event, payload=$payload]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'event'] = this.event;
    if (this.payload != null) {
      json[r'payload'] = this.payload;
    } else {
      json[r'payload'] = null;
    }
    return json;
  }

  /// Returns a new [SSEData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SSEData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SSEData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SSEData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SSEData(
        event: SSEDataEventEnum.fromJson(json[r'event'])!,
        payload: mapValueOfType<Object>(json, r'payload'),
      );
    }
    return null;
  }

  static List<SSEData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SSEData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SSEData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SSEData> mapFromJson(dynamic json) {
    final map = <String, SSEData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SSEData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SSEData-objects as value to a dart map
  static Map<String, List<SSEData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SSEData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SSEData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'event',
  };
}


class SSEDataEventEnum {
  /// Instantiate a new enum with the provided [value].
  const SSEDataEventEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const sync_ = SSEDataEventEnum._(r'sync');
  static const forceUpdate = SSEDataEventEnum._(r'force-update');
  static const notification = SSEDataEventEnum._(r'notification');

  /// List of all possible values in this [enum][SSEDataEventEnum].
  static const values = <SSEDataEventEnum>[
    sync_,
    forceUpdate,
    notification,
  ];

  static SSEDataEventEnum? fromJson(dynamic value) => SSEDataEventEnumTypeTransformer().decode(value);

  static List<SSEDataEventEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SSEDataEventEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SSEDataEventEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SSEDataEventEnum] to String,
/// and [decode] dynamic data back to [SSEDataEventEnum].
class SSEDataEventEnumTypeTransformer {
  factory SSEDataEventEnumTypeTransformer() => _instance ??= const SSEDataEventEnumTypeTransformer._();

  const SSEDataEventEnumTypeTransformer._();

  String encode(SSEDataEventEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SSEDataEventEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SSEDataEventEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'sync': return SSEDataEventEnum.sync_;
        case r'force-update': return SSEDataEventEnum.forceUpdate;
        case r'notification': return SSEDataEventEnum.notification;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SSEDataEventEnumTypeTransformer] instance.
  static SSEDataEventEnumTypeTransformer? _instance;
}


