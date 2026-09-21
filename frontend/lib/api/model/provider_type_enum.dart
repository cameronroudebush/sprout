//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


enum ProviderTypeEnum {
  simpleFin._(r'simple-fin'),
  zillow._(r'zillow'),
  plaid._(r'plaid'),
  snapTrade._(r'snapTrade'),
  coinbase._(r'coinbase'),
  ;

  /// Instantiate a new enum with the provided value.
  const ProviderTypeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ProviderTypeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ProviderTypeEnum? fromJson(dynamic value) => ProviderTypeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ProviderTypeEnum]
  /// that were successfully decoded from the passed [JSON][json].
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

  /// Encodes this enum as a value suitable for JSON.
  String encode(ProviderTypeEnum data) => data._value;

  /// Returns the instance of [ProviderTypeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ProviderTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ProviderTypeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'simple-fin': return ProviderTypeEnum.simpleFin;
        case r'zillow': return ProviderTypeEnum.zillow;
        case r'plaid': return ProviderTypeEnum.plaid;
        case r'snapTrade': return ProviderTypeEnum.snapTrade;
        case r'coinbase': return ProviderTypeEnum.coinbase;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ProviderTypeEnumTypeTransformer? _instance;
}

