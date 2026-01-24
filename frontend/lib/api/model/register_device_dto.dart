//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RegisterDeviceDto {
  /// Returns a new [RegisterDeviceDto] instance.
  RegisterDeviceDto({
    required this.token,
    this.platform,
    this.deviceName,
  });

  String token;

  RegisterDeviceDtoPlatformEnum? platform;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? deviceName;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RegisterDeviceDto &&
    other.token == token &&
    other.platform == platform &&
    other.deviceName == deviceName;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (token.hashCode) +
    (platform == null ? 0 : platform!.hashCode) +
    (deviceName == null ? 0 : deviceName!.hashCode);

  @override
  String toString() => 'RegisterDeviceDto[token=$token, platform=$platform, deviceName=$deviceName]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'token'] = this.token;
    if (this.platform != null) {
      json[r'platform'] = this.platform;
    } else {
      json[r'platform'] = null;
    }
    if (this.deviceName != null) {
      json[r'deviceName'] = this.deviceName;
    } else {
      json[r'deviceName'] = null;
    }
    return json;
  }

  /// Returns a new [RegisterDeviceDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RegisterDeviceDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RegisterDeviceDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RegisterDeviceDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RegisterDeviceDto(
        token: mapValueOfType<String>(json, r'token')!,
        platform: RegisterDeviceDtoPlatformEnum.fromJson(json[r'platform']),
        deviceName: mapValueOfType<String>(json, r'deviceName'),
      );
    }
    return null;
  }

  static List<RegisterDeviceDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegisterDeviceDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegisterDeviceDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RegisterDeviceDto> mapFromJson(dynamic json) {
    final map = <String, RegisterDeviceDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RegisterDeviceDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RegisterDeviceDto-objects as value to a dart map
  static Map<String, List<RegisterDeviceDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RegisterDeviceDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RegisterDeviceDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'token',
  };
}


class RegisterDeviceDtoPlatformEnum {
  /// Instantiate a new enum with the provided [value].
  const RegisterDeviceDtoPlatformEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const android = RegisterDeviceDtoPlatformEnum._(r'android');
  static const ios = RegisterDeviceDtoPlatformEnum._(r'ios');
  static const web = RegisterDeviceDtoPlatformEnum._(r'web');

  /// List of all possible values in this [enum][RegisterDeviceDtoPlatformEnum].
  static const values = <RegisterDeviceDtoPlatformEnum>[
    android,
    ios,
    web,
  ];

  static RegisterDeviceDtoPlatformEnum? fromJson(dynamic value) => RegisterDeviceDtoPlatformEnumTypeTransformer().decode(value);

  static List<RegisterDeviceDtoPlatformEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegisterDeviceDtoPlatformEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegisterDeviceDtoPlatformEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RegisterDeviceDtoPlatformEnum] to String,
/// and [decode] dynamic data back to [RegisterDeviceDtoPlatformEnum].
class RegisterDeviceDtoPlatformEnumTypeTransformer {
  factory RegisterDeviceDtoPlatformEnumTypeTransformer() => _instance ??= const RegisterDeviceDtoPlatformEnumTypeTransformer._();

  const RegisterDeviceDtoPlatformEnumTypeTransformer._();

  String encode(RegisterDeviceDtoPlatformEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a RegisterDeviceDtoPlatformEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RegisterDeviceDtoPlatformEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'android': return RegisterDeviceDtoPlatformEnum.android;
        case r'ios': return RegisterDeviceDtoPlatformEnum.ios;
        case r'web': return RegisterDeviceDtoPlatformEnum.web;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [RegisterDeviceDtoPlatformEnumTypeTransformer] instance.
  static RegisterDeviceDtoPlatformEnumTypeTransformer? _instance;
}


