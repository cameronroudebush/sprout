//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// What currency we should display everything in.
class CurrencyOptionsEnum {
  /// Instantiate a new enum with the provided [value].
  const CurrencyOptionsEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const USD = CurrencyOptionsEnum._(r'USD');
  static const EUR = CurrencyOptionsEnum._(r'EUR');
  static const GBP = CurrencyOptionsEnum._(r'GBP');
  static const CAD = CurrencyOptionsEnum._(r'CAD');
  static const AUD = CurrencyOptionsEnum._(r'AUD');
  static const JPY = CurrencyOptionsEnum._(r'JPY');
  static const CNY = CurrencyOptionsEnum._(r'CNY');

  /// List of all possible values in this [enum][CurrencyOptionsEnum].
  static const values = <CurrencyOptionsEnum>[
    USD,
    EUR,
    GBP,
    CAD,
    AUD,
    JPY,
    CNY,
  ];

  static CurrencyOptionsEnum? fromJson(dynamic value) => CurrencyOptionsEnumTypeTransformer().decode(value);

  static List<CurrencyOptionsEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CurrencyOptionsEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CurrencyOptionsEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CurrencyOptionsEnum] to String,
/// and [decode] dynamic data back to [CurrencyOptionsEnum].
class CurrencyOptionsEnumTypeTransformer {
  factory CurrencyOptionsEnumTypeTransformer() => _instance ??= const CurrencyOptionsEnumTypeTransformer._();

  const CurrencyOptionsEnumTypeTransformer._();

  String encode(CurrencyOptionsEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a CurrencyOptionsEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CurrencyOptionsEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'USD': return CurrencyOptionsEnum.USD;
        case r'EUR': return CurrencyOptionsEnum.EUR;
        case r'GBP': return CurrencyOptionsEnum.GBP;
        case r'CAD': return CurrencyOptionsEnum.CAD;
        case r'AUD': return CurrencyOptionsEnum.AUD;
        case r'JPY': return CurrencyOptionsEnum.JPY;
        case r'CNY': return CurrencyOptionsEnum.CNY;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [CurrencyOptionsEnumTypeTransformer] instance.
  static CurrencyOptionsEnumTypeTransformer? _instance;
}

