//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Holding {
  /// Returns a new [Holding] instance.
  Holding({
    required this.id,
    required this.accountId,
    required this.purchasePrice,
    required this.costBasis,
    required this.marketValue,
    required this.description,
    required this.shares,
    required this.symbol,
  });

  String id;

  /// The Id of the account related to this holding.
  String accountId;

  /// The numeric value converted to the user's preferred currency format. This overrides the original purchasePrice property.
  num purchasePrice;

  /// The numeric value converted to the user's preferred currency format. This overrides the original costBasis property.
  num costBasis;

  /// The numeric value converted to the user's preferred currency format. This overrides the original marketValue property.
  num marketValue;

  /// A description of what this holding is
  String description;

  /// Total number of shares, including fractional
  num shares;

  /// The symbol for this holding
  String symbol;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Holding &&
    other.id == id &&
    other.accountId == accountId &&
    other.purchasePrice == purchasePrice &&
    other.costBasis == costBasis &&
    other.marketValue == marketValue &&
    other.description == description &&
    other.shares == shares &&
    other.symbol == symbol;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (accountId.hashCode) +
    (purchasePrice.hashCode) +
    (costBasis.hashCode) +
    (marketValue.hashCode) +
    (description.hashCode) +
    (shares.hashCode) +
    (symbol.hashCode);

  @override
  String toString() => 'Holding[id=$id, accountId=$accountId, purchasePrice=$purchasePrice, costBasis=$costBasis, marketValue=$marketValue, description=$description, shares=$shares, symbol=$symbol]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'accountId'] = this.accountId;
      json[r'purchasePrice'] = this.purchasePrice;
      json[r'costBasis'] = this.costBasis;
      json[r'marketValue'] = this.marketValue;
      json[r'description'] = this.description;
      json[r'shares'] = this.shares;
      json[r'symbol'] = this.symbol;
    return json;
  }

  /// Returns a new [Holding] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Holding? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Holding[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Holding[id]" has a null value in JSON.');
        assert(json.containsKey(r'accountId'), 'Required key "Holding[accountId]" is missing from JSON.');
        assert(json[r'accountId'] != null, 'Required key "Holding[accountId]" has a null value in JSON.');
        assert(json.containsKey(r'purchasePrice'), 'Required key "Holding[purchasePrice]" is missing from JSON.');
        assert(json[r'purchasePrice'] != null, 'Required key "Holding[purchasePrice]" has a null value in JSON.');
        assert(json.containsKey(r'costBasis'), 'Required key "Holding[costBasis]" is missing from JSON.');
        assert(json[r'costBasis'] != null, 'Required key "Holding[costBasis]" has a null value in JSON.');
        assert(json.containsKey(r'marketValue'), 'Required key "Holding[marketValue]" is missing from JSON.');
        assert(json[r'marketValue'] != null, 'Required key "Holding[marketValue]" has a null value in JSON.');
        assert(json.containsKey(r'description'), 'Required key "Holding[description]" is missing from JSON.');
        assert(json[r'description'] != null, 'Required key "Holding[description]" has a null value in JSON.');
        assert(json.containsKey(r'shares'), 'Required key "Holding[shares]" is missing from JSON.');
        assert(json[r'shares'] != null, 'Required key "Holding[shares]" has a null value in JSON.');
        assert(json.containsKey(r'symbol'), 'Required key "Holding[symbol]" is missing from JSON.');
        assert(json[r'symbol'] != null, 'Required key "Holding[symbol]" has a null value in JSON.');
        return true;
      }());

      return Holding(
        id: mapValueOfType<String>(json, r'id')!,
        accountId: mapValueOfType<String>(json, r'accountId')!,
        purchasePrice: num.parse('${json[r'purchasePrice']}'),
        costBasis: num.parse('${json[r'costBasis']}'),
        marketValue: num.parse('${json[r'marketValue']}'),
        description: mapValueOfType<String>(json, r'description')!,
        shares: num.parse('${json[r'shares']}'),
        symbol: mapValueOfType<String>(json, r'symbol')!,
      );
    }
    return null;
  }

  static List<Holding> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Holding>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Holding.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Holding> mapFromJson(dynamic json) {
    final map = <String, Holding>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Holding.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Holding-objects as value to a dart map
  static Map<String, List<Holding>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Holding>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Holding.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'accountId',
    'purchasePrice',
    'costBasis',
    'marketValue',
    'description',
    'shares',
    'symbol',
  };
}

