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
    required this.symbol,
    required this.name,
    required this.price,
    this.currency,
    required this.change,
    required this.changePercent,
    required this.lastUpdated,
  });

  String symbol;

  String name;

  num price;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? currency;

  num change;

  num changePercent;

  String lastUpdated;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MarketIndexDto &&
    other.symbol == symbol &&
    other.name == name &&
    other.price == price &&
    other.currency == currency &&
    other.change == change &&
    other.changePercent == changePercent &&
    other.lastUpdated == lastUpdated;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (symbol.hashCode) +
    (name.hashCode) +
    (price.hashCode) +
    (currency == null ? 0 : currency!.hashCode) +
    (change.hashCode) +
    (changePercent.hashCode) +
    (lastUpdated.hashCode);

  @override
  String toString() => 'MarketIndexDto[symbol=$symbol, name=$name, price=$price, currency=$currency, change=$change, changePercent=$changePercent, lastUpdated=$lastUpdated]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'symbol'] = this.symbol;
      json[r'name'] = this.name;
      json[r'price'] = this.price;
    if (this.currency != null) {
      json[r'currency'] = this.currency;
    } else {
      json[r'currency'] = null;
    }
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
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MarketIndexDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MarketIndexDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MarketIndexDto(
        symbol: mapValueOfType<String>(json, r'symbol')!,
        name: mapValueOfType<String>(json, r'name')!,
        price: num.parse('${json[r'price']}'),
        currency: mapValueOfType<String>(json, r'currency'),
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
    'symbol',
    'name',
    'price',
    'change',
    'changePercent',
    'lastUpdated',
  };
}

