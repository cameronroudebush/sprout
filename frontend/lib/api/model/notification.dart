//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Notification {
  /// Returns a new [Notification] instance.
  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.readAt,
  });

  String id;

  /// The title for our notification
  String title;

  /// The message that this notification intended to show the user
  String message;

  /// The type of notification this is
  NotificationTypeEnum type;

  /// The date that this notification occurs on
  DateTime createdAt;

  /// Tracks if the user has interacted with this notification yet.
  bool isRead;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? readAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Notification &&
    other.id == id &&
    other.title == title &&
    other.message == message &&
    other.type == type &&
    other.createdAt == createdAt &&
    other.isRead == isRead &&
    other.readAt == readAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (title.hashCode) +
    (message.hashCode) +
    (type.hashCode) +
    (createdAt.hashCode) +
    (isRead.hashCode) +
    (readAt == null ? 0 : readAt!.hashCode);

  @override
  String toString() => 'Notification[id=$id, title=$title, message=$message, type=$type, createdAt=$createdAt, isRead=$isRead, readAt=$readAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'title'] = this.title;
      json[r'message'] = this.message;
      json[r'type'] = this.type;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'isRead'] = this.isRead;
    if (this.readAt != null) {
      json[r'readAt'] = this.readAt!.toUtc().toIso8601String();
    } else {
      json[r'readAt'] = null;
    }
    return json;
  }

  /// Returns a new [Notification] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Notification? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Notification[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Notification[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Notification(
        id: mapValueOfType<String>(json, r'id')!,
        title: mapValueOfType<String>(json, r'title')!,
        message: mapValueOfType<String>(json, r'message')!,
        type: NotificationTypeEnum.fromJson(json[r'type'])!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        isRead: mapValueOfType<bool>(json, r'isRead')!,
        readAt: mapDateTime(json, r'readAt', r''),
      );
    }
    return null;
  }

  static List<Notification> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Notification>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Notification.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Notification> mapFromJson(dynamic json) {
    final map = <String, Notification>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Notification.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Notification-objects as value to a dart map
  static Map<String, List<Notification>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Notification>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Notification.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'title',
    'message',
    'type',
    'createdAt',
    'isRead',
  };
}

/// The type of notification this is
class NotificationTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const NotificationTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const info = NotificationTypeEnum._(r'info');
  static const success = NotificationTypeEnum._(r'success');
  static const warning = NotificationTypeEnum._(r'warning');
  static const error = NotificationTypeEnum._(r'error');

  /// List of all possible values in this [enum][NotificationTypeEnum].
  static const values = <NotificationTypeEnum>[
    info,
    success,
    warning,
    error,
  ];

  static NotificationTypeEnum? fromJson(dynamic value) => NotificationTypeEnumTypeTransformer().decode(value);

  static List<NotificationTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NotificationTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NotificationTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [NotificationTypeEnum] to String,
/// and [decode] dynamic data back to [NotificationTypeEnum].
class NotificationTypeEnumTypeTransformer {
  factory NotificationTypeEnumTypeTransformer() => _instance ??= const NotificationTypeEnumTypeTransformer._();

  const NotificationTypeEnumTypeTransformer._();

  String encode(NotificationTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a NotificationTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  NotificationTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'info': return NotificationTypeEnum.info;
        case r'success': return NotificationTypeEnum.success;
        case r'warning': return NotificationTypeEnum.warning;
        case r'error': return NotificationTypeEnum.error;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [NotificationTypeEnumTypeTransformer] instance.
  static NotificationTypeEnumTypeTransformer? _instance;
}


