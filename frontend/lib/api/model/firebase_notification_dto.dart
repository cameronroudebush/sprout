//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class FirebaseNotificationDTO {
  /// Returns a new [FirebaseNotificationDTO] instance.
  FirebaseNotificationDTO({
    required this.notificationId,
    this.type = 'secure_message',
    this.importance = const FirebaseNotificationDTOImportanceEnum._('low'),
  });

  String notificationId;

  String type;

  /// Notification importance level
  FirebaseNotificationDTOImportanceEnum importance;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FirebaseNotificationDTO &&
    other.notificationId == notificationId &&
    other.type == type &&
    other.importance == importance;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (notificationId.hashCode) +
    (type.hashCode) +
    (importance.hashCode);

  @override
  String toString() => 'FirebaseNotificationDTO[notificationId=$notificationId, type=$type, importance=$importance]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'notificationId'] = this.notificationId;
      json[r'type'] = this.type;
      json[r'importance'] = this.importance;
    return json;
  }

  /// Returns a new [FirebaseNotificationDTO] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FirebaseNotificationDTO? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FirebaseNotificationDTO[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FirebaseNotificationDTO[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FirebaseNotificationDTO(
        notificationId: mapValueOfType<String>(json, r'notificationId')!,
        type: mapValueOfType<String>(json, r'type')!,
        importance: FirebaseNotificationDTOImportanceEnum.fromJson(json[r'importance'])!,
      );
    }
    return null;
  }

  static List<FirebaseNotificationDTO> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FirebaseNotificationDTO>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FirebaseNotificationDTO.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FirebaseNotificationDTO> mapFromJson(dynamic json) {
    final map = <String, FirebaseNotificationDTO>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FirebaseNotificationDTO.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FirebaseNotificationDTO-objects as value to a dart map
  static Map<String, List<FirebaseNotificationDTO>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FirebaseNotificationDTO>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FirebaseNotificationDTO.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'notificationId',
    'type',
    'importance',
  };
}

/// Notification importance level
class FirebaseNotificationDTOImportanceEnum {
  /// Instantiate a new enum with the provided [value].
  const FirebaseNotificationDTOImportanceEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const max = FirebaseNotificationDTOImportanceEnum._(r'max');
  static const high = FirebaseNotificationDTOImportanceEnum._(r'high');
  static const default_ = FirebaseNotificationDTOImportanceEnum._(r'default');
  static const low = FirebaseNotificationDTOImportanceEnum._(r'low');

  /// List of all possible values in this [enum][FirebaseNotificationDTOImportanceEnum].
  static const values = <FirebaseNotificationDTOImportanceEnum>[
    max,
    high,
    default_,
    low,
  ];

  static FirebaseNotificationDTOImportanceEnum? fromJson(dynamic value) => FirebaseNotificationDTOImportanceEnumTypeTransformer().decode(value);

  static List<FirebaseNotificationDTOImportanceEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FirebaseNotificationDTOImportanceEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FirebaseNotificationDTOImportanceEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [FirebaseNotificationDTOImportanceEnum] to String,
/// and [decode] dynamic data back to [FirebaseNotificationDTOImportanceEnum].
class FirebaseNotificationDTOImportanceEnumTypeTransformer {
  factory FirebaseNotificationDTOImportanceEnumTypeTransformer() => _instance ??= const FirebaseNotificationDTOImportanceEnumTypeTransformer._();

  const FirebaseNotificationDTOImportanceEnumTypeTransformer._();

  String encode(FirebaseNotificationDTOImportanceEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a FirebaseNotificationDTOImportanceEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  FirebaseNotificationDTOImportanceEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'max': return FirebaseNotificationDTOImportanceEnum.max;
        case r'high': return FirebaseNotificationDTOImportanceEnum.high;
        case r'default': return FirebaseNotificationDTOImportanceEnum.default_;
        case r'low': return FirebaseNotificationDTOImportanceEnum.low;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [FirebaseNotificationDTOImportanceEnumTypeTransformer] instance.
  static FirebaseNotificationDTOImportanceEnumTypeTransformer? _instance;
}


