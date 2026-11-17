//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ProviderCredentialsModeEnum {
  /// Instantiate a new enum with the provided [value].
  const ProviderCredentialsModeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const system = ProviderCredentialsModeEnum._(r'system');
  static const user = ProviderCredentialsModeEnum._(r'user');

  /// List of all possible values in this [enum][ProviderCredentialsModeEnum].
  static const values = <ProviderCredentialsModeEnum>[
    system,
    user,
  ];

  static ProviderCredentialsModeEnum? fromJson(dynamic value) =>
      ProviderCredentialsModeEnumTypeTransformer().decode(value);

  static List<ProviderCredentialsModeEnum> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ProviderCredentialsModeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProviderCredentialsModeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ProviderCredentialsModeEnum] to String,
/// and [decode] dynamic data back to [ProviderCredentialsModeEnum].
class ProviderCredentialsModeEnumTypeTransformer {
  factory ProviderCredentialsModeEnumTypeTransformer() =>
      _instance ??= const ProviderCredentialsModeEnumTypeTransformer._();

  const ProviderCredentialsModeEnumTypeTransformer._();

  String encode(ProviderCredentialsModeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ProviderCredentialsModeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ProviderCredentialsModeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'system':
          return ProviderCredentialsModeEnum.system;
        case r'user':
          return ProviderCredentialsModeEnum.user;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ProviderCredentialsModeEnumTypeTransformer] instance.
  static ProviderCredentialsModeEnumTypeTransformer? _instance;
}
