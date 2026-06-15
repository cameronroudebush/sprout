//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MarketIndexDto {
  /// Returns a new [MarketIndexDto] instance.
  MarketIndexDto({
    this.previousClose,
    this.dayLow,
    this.dayHigh,
    this.marketState,
    this.dividendYield,
    required this.price,
    required this.symbol,
    required this.name,
    required this.change,
    required this.changePercent,
    required this.lastUpdated,
  });

  num? previousClose;

  num? dayLow;

  num? dayHigh;

  MarketIndexDtoMarketStateEnum? marketState;

  /// Annual dividend yield as a full percentage (e.g., 1.5 for 1.5%)
  num? dividendYield;

  /// The numeric value converted to the user's preferred currency format. This overrides the original price property.
  num price;

  String symbol;

  String name;

  num change;

  num changePercent;

  String lastUpdated;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MarketIndexDto &&
    other.previousClose == previousClose &&
    other.dayLow == dayLow &&
    other.dayHigh == dayHigh &&
    other.marketState == marketState &&
    other.dividendYield == dividendYield &&
    other.price == price &&
    other.symbol == symbol &&
    other.name == name &&
    other.change == change &&
    other.changePercent == changePercent &&
    other.lastUpdated == lastUpdated;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (previousClose == null ? 0 : previousClose!.hashCode) +
    (dayLow == null ? 0 : dayLow!.hashCode) +
    (dayHigh == null ? 0 : dayHigh!.hashCode) +
    (marketState == null ? 0 : marketState!.hashCode) +
    (dividendYield == null ? 0 : dividendYield!.hashCode) +
    (price.hashCode) +
    (symbol.hashCode) +
    (name.hashCode) +
    (change.hashCode) +
    (changePercent.hashCode) +
    (lastUpdated.hashCode);

  @override
  String toString() => 'MarketIndexDto[previousClose=$previousClose, dayLow=$dayLow, dayHigh=$dayHigh, marketState=$marketState, dividendYield=$dividendYield, price=$price, symbol=$symbol, name=$name, change=$change, changePercent=$changePercent, lastUpdated=$lastUpdated]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.previousClose != null) {
      json[r'previousClose'] = this.previousClose;
    } else {
      json[r'previousClose'] = null;
    }
    if (this.dayLow != null) {
      json[r'dayLow'] = this.dayLow;
    } else {
      json[r'dayLow'] = null;
    }
    if (this.dayHigh != null) {
      json[r'dayHigh'] = this.dayHigh;
    } else {
      json[r'dayHigh'] = null;
    }
    if (this.marketState != null) {
      json[r'marketState'] = this.marketState;
    } else {
      json[r'marketState'] = null;
    }
    if (this.dividendYield != null) {
      json[r'dividendYield'] = this.dividendYield;
    } else {
      json[r'dividendYield'] = null;
    }
      json[r'price'] = this.price;
      json[r'symbol'] = this.symbol;
      json[r'name'] = this.name;
      json[r'change'] = this.change;
      json[r'changePercent'] = this.changePercent;
      json[r'lastUpdated'] = this.lastUpdated;
    return json;
  }

  /// Returns a new [MarketIndexDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MarketIndexDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'price'), 'Required key "MarketIndexDto[price]" is missing from JSON.');
        assert(json[r'price'] != null, 'Required key "MarketIndexDto[price]" has a null value in JSON.');
        assert(json.containsKey(r'symbol'), 'Required key "MarketIndexDto[symbol]" is missing from JSON.');
        assert(json[r'symbol'] != null, 'Required key "MarketIndexDto[symbol]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "MarketIndexDto[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "MarketIndexDto[name]" has a null value in JSON.');
        assert(json.containsKey(r'change'), 'Required key "MarketIndexDto[change]" is missing from JSON.');
        assert(json[r'change'] != null, 'Required key "MarketIndexDto[change]" has a null value in JSON.');
        assert(json.containsKey(r'changePercent'), 'Required key "MarketIndexDto[changePercent]" is missing from JSON.');
        assert(json[r'changePercent'] != null, 'Required key "MarketIndexDto[changePercent]" has a null value in JSON.');
        assert(json.containsKey(r'lastUpdated'), 'Required key "MarketIndexDto[lastUpdated]" is missing from JSON.');
        assert(json[r'lastUpdated'] != null, 'Required key "MarketIndexDto[lastUpdated]" has a null value in JSON.');
        return true;
      }());

      return MarketIndexDto(
        previousClose: json[r'previousClose'] == null
            ? null
            : num.parse('${json[r'previousClose']}'),
        dayLow: json[r'dayLow'] == null
            ? null
            : num.parse('${json[r'dayLow']}'),
        dayHigh: json[r'dayHigh'] == null
            ? null
            : num.parse('${json[r'dayHigh']}'),
        marketState: MarketIndexDtoMarketStateEnum.fromJson(json[r'marketState']),
        dividendYield: json[r'dividendYield'] == null
            ? null
            : num.parse('${json[r'dividendYield']}'),
        price: num.parse('${json[r'price']}'),
        symbol: mapValueOfType<String>(json, r'symbol')!,
        name: mapValueOfType<String>(json, r'name')!,
        change: num.parse('${json[r'change']}'),
        changePercent: num.parse('${json[r'changePercent']}'),
        lastUpdated: mapValueOfType<String>(json, r'lastUpdated')!,
      );
    }
    return null;
  }

  static List<MarketIndexDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MarketIndexDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MarketIndexDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MarketIndexDto> mapFromJson(dynamic json) {
    final map = <String, MarketIndexDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MarketIndexDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MarketIndexDto-objects as value to a dart map
  static Map<String, List<MarketIndexDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MarketIndexDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MarketIndexDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'price',
    'symbol',
    'name',
    'change',
    'changePercent',
    'lastUpdated',
  };
}


class MarketIndexDtoMarketStateEnum {
  /// Instantiate a new enum with the provided [value].
  const MarketIndexDtoMarketStateEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const REGULAR = MarketIndexDtoMarketStateEnum._(r'REGULAR');
  static const CLOSED = MarketIndexDtoMarketStateEnum._(r'CLOSED');
  static const PRE = MarketIndexDtoMarketStateEnum._(r'PRE');
  static const POST = MarketIndexDtoMarketStateEnum._(r'POST');
  static const PREPRE = MarketIndexDtoMarketStateEnum._(r'PREPRE');
  static const POSTPOST = MarketIndexDtoMarketStateEnum._(r'POSTPOST');

  /// List of all possible values in this [enum][MarketIndexDtoMarketStateEnum].
  static const values = <MarketIndexDtoMarketStateEnum>[
    REGULAR,
    CLOSED,
    PRE,
    POST,
    PREPRE,
    POSTPOST,
  ];

  static MarketIndexDtoMarketStateEnum? fromJson(dynamic value) => MarketIndexDtoMarketStateEnumTypeTransformer().decode(value);

  static List<MarketIndexDtoMarketStateEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MarketIndexDtoMarketStateEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MarketIndexDtoMarketStateEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MarketIndexDtoMarketStateEnum] to String,
/// and [decode] dynamic data back to [MarketIndexDtoMarketStateEnum].
class MarketIndexDtoMarketStateEnumTypeTransformer {
  factory MarketIndexDtoMarketStateEnumTypeTransformer() => _instance ??= const MarketIndexDtoMarketStateEnumTypeTransformer._();

  const MarketIndexDtoMarketStateEnumTypeTransformer._();

  String encode(MarketIndexDtoMarketStateEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MarketIndexDtoMarketStateEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MarketIndexDtoMarketStateEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'REGULAR': return MarketIndexDtoMarketStateEnum.REGULAR;
        case r'CLOSED': return MarketIndexDtoMarketStateEnum.CLOSED;
        case r'PRE': return MarketIndexDtoMarketStateEnum.PRE;
        case r'POST': return MarketIndexDtoMarketStateEnum.POST;
        case r'PREPRE': return MarketIndexDtoMarketStateEnum.PREPRE;
        case r'POSTPOST': return MarketIndexDtoMarketStateEnum.POSTPOST;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MarketIndexDtoMarketStateEnumTypeTransformer] instance.
  static MarketIndexDtoMarketStateEnumTypeTransformer? _instance;
}


