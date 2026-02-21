//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ModelSync {
  /// Returns a new [ModelSync] instance.
  ModelSync({
    required this.id,
    required this.status,
    required this.time,
    this.failureReason,
    this.user,
  });

  String id;

  /// The status of the sync job
  ModelSyncStatusEnum status;

  /// When this was started
  DateTime time;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? failureReason;

  /// This user properly allows us to track if this sync was for a specific user
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  User? user;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ModelSync &&
    other.id == id &&
    other.status == status &&
    other.time == time &&
    other.failureReason == failureReason &&
    other.user == user;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (status.hashCode) +
    (time.hashCode) +
    (failureReason == null ? 0 : failureReason!.hashCode) +
    (user == null ? 0 : user!.hashCode);

  @override
  String toString() => 'ModelSync[id=$id, status=$status, time=$time, failureReason=$failureReason, user=$user]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'status'] = this.status;
      json[r'time'] = this.time.toUtc().toIso8601String();
    if (this.failureReason != null) {
      json[r'failureReason'] = this.failureReason;
    } else {
      json[r'failureReason'] = null;
    }
    if (this.user != null) {
      json[r'user'] = this.user;
    } else {
      json[r'user'] = null;
    }
    return json;
  }

  /// Returns a new [ModelSync] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ModelSync? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ModelSync[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ModelSync[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ModelSync(
        id: mapValueOfType<String>(json, r'id')!,
        status: ModelSyncStatusEnum.fromJson(json[r'status'])!,
        time: mapDateTime(json, r'time', r'')!,
        failureReason: mapValueOfType<String>(json, r'failureReason'),
        user: User.fromJson(json[r'user']),
      );
    }
    return null;
  }

  static List<ModelSync> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ModelSync>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ModelSync.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ModelSync> mapFromJson(dynamic json) {
    final map = <String, ModelSync>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ModelSync.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ModelSync-objects as value to a dart map
  static Map<String, List<ModelSync>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ModelSync>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ModelSync.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'status',
    'time',
  };
}

/// The status of the sync job
class ModelSyncStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const ModelSyncStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const inProgress = ModelSyncStatusEnum._(r'in-progress');
  static const complete = ModelSyncStatusEnum._(r'complete');
  static const failed = ModelSyncStatusEnum._(r'failed');

  /// List of all possible values in this [enum][ModelSyncStatusEnum].
  static const values = <ModelSyncStatusEnum>[
    inProgress,
    complete,
    failed,
  ];

  static ModelSyncStatusEnum? fromJson(dynamic value) => ModelSyncStatusEnumTypeTransformer().decode(value);

  static List<ModelSyncStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ModelSyncStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ModelSyncStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ModelSyncStatusEnum] to String,
/// and [decode] dynamic data back to [ModelSyncStatusEnum].
class ModelSyncStatusEnumTypeTransformer {
  factory ModelSyncStatusEnumTypeTransformer() => _instance ??= const ModelSyncStatusEnumTypeTransformer._();

  const ModelSyncStatusEnumTypeTransformer._();

  String encode(ModelSyncStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ModelSyncStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ModelSyncStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'in-progress': return ModelSyncStatusEnum.inProgress;
        case r'complete': return ModelSyncStatusEnum.complete;
        case r'failed': return ModelSyncStatusEnum.failed;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ModelSyncStatusEnumTypeTransformer] instance.
  static ModelSyncStatusEnumTypeTransformer? _instance;
}


