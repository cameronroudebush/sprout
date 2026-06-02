//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ProviderSubTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const ProviderSubTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const bankInvestments = ProviderSubTypeEnum._(r'Bank Investments');
  static const realEstate = ProviderSubTypeEnum._(r'Real Estate');

  /// List of all possible values in this [enum][ProviderSubTypeEnum].
  static const values = <ProviderSubTypeEnum>[
    bankInvestments,
    realEstate,
  ];

  static ProviderSubTypeEnum? fromJson(dynamic value) => ProviderSubTypeEnumTypeTransformer().decode(value);

  static List<ProviderSubTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProviderSubTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProviderSubTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ProviderSubTypeEnum] to String,
/// and [decode] dynamic data back to [ProviderSubTypeEnum].
class ProviderSubTypeEnumTypeTransformer {
  factory ProviderSubTypeEnumTypeTransformer() => _instance ??= const ProviderSubTypeEnumTypeTransformer._();

  const ProviderSubTypeEnumTypeTransformer._();

  String encode(ProviderSubTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ProviderSubTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ProviderSubTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'Bank Investments': return ProviderSubTypeEnum.bankInvestments;
        case r'Real Estate': return ProviderSubTypeEnum.realEstate;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ProviderSubTypeEnumTypeTransformer] instance.
  static ProviderSubTypeEnumTypeTransformer? _instance;
}

