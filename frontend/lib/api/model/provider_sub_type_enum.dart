//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


enum ProviderSubTypeEnum {
  bankInvestments._(r'Bank Investments'),
  realEstate._(r'Real Estate'),
  crypto._(r'Crypto'),
  ;

  /// Instantiate a new enum with the provided value.
  const ProviderSubTypeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ProviderSubTypeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ProviderSubTypeEnum? fromJson(dynamic value) => ProviderSubTypeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ProviderSubTypeEnum]
  /// that were successfully decoded from the passed [JSON][json].
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

  /// Encodes this enum as a value suitable for JSON.
  String encode(ProviderSubTypeEnum data) => data._value;

  /// Returns the instance of [ProviderSubTypeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ProviderSubTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ProviderSubTypeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'Bank Investments': return ProviderSubTypeEnum.bankInvestments;
        case r'Real Estate': return ProviderSubTypeEnum.realEstate;
        case r'Crypto': return ProviderSubTypeEnum.crypto;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ProviderSubTypeEnumTypeTransformer? _instance;
}

