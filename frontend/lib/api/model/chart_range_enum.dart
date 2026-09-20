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
enum ChartRangeEnum {
  oneDay._(r'oneDay'),
  sevenDays._(r'sevenDays'),
  oneMonth._(r'oneMonth'),
  threeMonths._(r'threeMonths'),
  sixMonths._(r'sixMonths'),
  oneYear._(r'oneYear'),
  allTime._(r'allTime'),
  ;

  /// Instantiate a new enum with the provided value.
  const ChartRangeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ChartRangeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ChartRangeEnum? fromJson(dynamic value) => ChartRangeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ChartRangeEnum]
  /// that were successfully decoded from the passed [JSON][json].
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

  /// Encodes this enum as a value suitable for JSON.
  String encode(ChartRangeEnum data) => data._value;

  /// Returns the instance of [ChartRangeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ChartRangeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ChartRangeEnum) {
      return data;
    }
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

  /// The singleton instance of this transformer.
  static ChartRangeEnumTypeTransformer? _instance;
}

