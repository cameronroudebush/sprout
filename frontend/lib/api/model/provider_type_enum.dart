//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ProviderTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const ProviderTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const simpleFin = ProviderTypeEnum._(r'simple-fin');
  static const zillow = ProviderTypeEnum._(r'zillow');

  /// List of all possible values in this [enum][ProviderTypeEnum].
  static const values = <ProviderTypeEnum>[
    simpleFin,
    zillow,
  ];

  static ProviderTypeEnum? fromJson(dynamic value) => ProviderTypeEnumTypeTransformer().decode(value);

  static List<ProviderTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProviderTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProviderTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ProviderTypeEnum] to String,
/// and [decode] dynamic data back to [ProviderTypeEnum].
class ProviderTypeEnumTypeTransformer {
  factory ProviderTypeEnumTypeTransformer() => _instance ??= const ProviderTypeEnumTypeTransformer._();

  const ProviderTypeEnumTypeTransformer._();

  String encode(ProviderTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ProviderTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ProviderTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'simple-fin': return ProviderTypeEnum.simpleFin;
        case r'zillow': return ProviderTypeEnum.zillow;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ProviderTypeEnumTypeTransformer] instance.
  static ProviderTypeEnumTypeTransformer? _instance;
}

