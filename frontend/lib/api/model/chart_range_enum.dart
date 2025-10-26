//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// The net worth range to display by default
class ChartRangeEnum {
  /// Instantiate a new enum with the provided [value].
  const ChartRangeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const oneDay = ChartRangeEnum._(r'oneDay');
  static const sevenDays = ChartRangeEnum._(r'sevenDays');
  static const oneMonth = ChartRangeEnum._(r'oneMonth');
  static const threeMonths = ChartRangeEnum._(r'threeMonths');
  static const sixMonths = ChartRangeEnum._(r'sixMonths');
  static const oneYear = ChartRangeEnum._(r'oneYear');
  static const allTime = ChartRangeEnum._(r'allTime');

  /// List of all possible values in this [enum][ChartRangeEnum].
  static const values = <ChartRangeEnum>[
    oneDay,
    sevenDays,
    oneMonth,
    threeMonths,
    sixMonths,
    oneYear,
    allTime,
  ];

  static ChartRangeEnum? fromJson(dynamic value) => ChartRangeEnumTypeTransformer().decode(value);

  static List<ChartRangeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChartRangeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChartRangeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ChartRangeEnum] to String,
/// and [decode] dynamic data back to [ChartRangeEnum].
class ChartRangeEnumTypeTransformer {
  factory ChartRangeEnumTypeTransformer() => _instance ??= const ChartRangeEnumTypeTransformer._();

  const ChartRangeEnumTypeTransformer._();

  String encode(ChartRangeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ChartRangeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ChartRangeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'oneDay': return ChartRangeEnum.oneDay;
        case r'sevenDays': return ChartRangeEnum.sevenDays;
        case r'oneMonth': return ChartRangeEnum.oneMonth;
        case r'threeMonths': return ChartRangeEnum.threeMonths;
        case r'sixMonths': return ChartRangeEnum.sixMonths;
        case r'oneYear': return ChartRangeEnum.oneYear;
        case r'allTime': return ChartRangeEnum.allTime;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ChartRangeEnumTypeTransformer] instance.
  static ChartRangeEnumTypeTransformer? _instance;
}

