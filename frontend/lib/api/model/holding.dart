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
    required this.account,
    required this.currency,
    required this.costBasis,
    required this.description,
    required this.marketValue,
    required this.purchasePrice,
    required this.shares,
    required this.symbol,
  });

  String id;

  /// The account this holding is associated to
  Account account;

  String currency;

  num costBasis;

  /// A description of what this holding is
  String description;

  /// The current market value
  num marketValue;

  /// The current purchase price
  num purchasePrice;

  /// Total number of shares, including fractional
  num shares;

  /// The symbol for this holding
  String symbol;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Holding &&
    other.id == id &&
    other.account == account &&
    other.currency == currency &&
    other.costBasis == costBasis &&
    other.description == description &&
    other.marketValue == marketValue &&
    other.purchasePrice == purchasePrice &&
    other.shares == shares &&
    other.symbol == symbol;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (account.hashCode) +
    (currency.hashCode) +
    (costBasis.hashCode) +
    (description.hashCode) +
    (marketValue.hashCode) +
    (purchasePrice.hashCode) +
    (shares.hashCode) +
    (symbol.hashCode);

  @override
  String toString() => 'Holding[id=$id, account=$account, currency=$currency, costBasis=$costBasis, description=$description, marketValue=$marketValue, purchasePrice=$purchasePrice, shares=$shares, symbol=$symbol]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'account'] = this.account;
      json[r'currency'] = this.currency;
      json[r'costBasis'] = this.costBasis;
      json[r'description'] = this.description;
      json[r'marketValue'] = this.marketValue;
      json[r'purchasePrice'] = this.purchasePrice;
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
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Holding[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Holding[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Holding(
        id: mapValueOfType<String>(json, r'id')!,
        account: Account.fromJson(json[r'account'])!,
        currency: mapValueOfType<String>(json, r'currency')!,
        costBasis: num.parse('${json[r'costBasis']}'),
        description: mapValueOfType<String>(json, r'description')!,
        marketValue: num.parse('${json[r'marketValue']}'),
        purchasePrice: num.parse('${json[r'purchasePrice']}'),
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
    'account',
    'currency',
    'costBasis',
    'description',
    'marketValue',
    'purchasePrice',
    'shares',
    'symbol',
  };
}

