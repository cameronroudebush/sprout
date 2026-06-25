//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TransactionLocation {
  /// Returns a new [TransactionLocation] instance.
  TransactionLocation({
    this.address,
    this.city,
    this.country,
    this.lat,
    this.lon,
    this.postalCode,
    this.region,
    this.storeNumber,
  });

  String? address;

  String? city;

  String? country;

  num? lat;

  num? lon;

  String? postalCode;

  String? region;

  String? storeNumber;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TransactionLocation &&
    other.address == address &&
    other.city == city &&
    other.country == country &&
    other.lat == lat &&
    other.lon == lon &&
    other.postalCode == postalCode &&
    other.region == region &&
    other.storeNumber == storeNumber;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (address == null ? 0 : address!.hashCode) +
    (city == null ? 0 : city!.hashCode) +
    (country == null ? 0 : country!.hashCode) +
    (lat == null ? 0 : lat!.hashCode) +
    (lon == null ? 0 : lon!.hashCode) +
    (postalCode == null ? 0 : postalCode!.hashCode) +
    (region == null ? 0 : region!.hashCode) +
    (storeNumber == null ? 0 : storeNumber!.hashCode);

  @override
  String toString() => 'TransactionLocation[address=$address, city=$city, country=$country, lat=$lat, lon=$lon, postalCode=$postalCode, region=$region, storeNumber=$storeNumber]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.address != null) {
      json[r'address'] = this.address;
    } else {
      json[r'address'] = null;
    }
    if (this.city != null) {
      json[r'city'] = this.city;
    } else {
      json[r'city'] = null;
    }
    if (this.country != null) {
      json[r'country'] = this.country;
    } else {
      json[r'country'] = null;
    }
    if (this.lat != null) {
      json[r'lat'] = this.lat;
    } else {
      json[r'lat'] = null;
    }
    if (this.lon != null) {
      json[r'lon'] = this.lon;
    } else {
      json[r'lon'] = null;
    }
    if (this.postalCode != null) {
      json[r'postal_code'] = this.postalCode;
    } else {
      json[r'postal_code'] = null;
    }
    if (this.region != null) {
      json[r'region'] = this.region;
    } else {
      json[r'region'] = null;
    }
    if (this.storeNumber != null) {
      json[r'store_number'] = this.storeNumber;
    } else {
      json[r'store_number'] = null;
    }
    return json;
  }

  /// Returns a new [TransactionLocation] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TransactionLocation? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return TransactionLocation(
        address: mapValueOfType<String>(json, r'address'),
        city: mapValueOfType<String>(json, r'city'),
        country: mapValueOfType<String>(json, r'country'),
        lat: json[r'lat'] == null
            ? null
            : num.parse('${json[r'lat']}'),
        lon: json[r'lon'] == null
            ? null
            : num.parse('${json[r'lon']}'),
        postalCode: mapValueOfType<String>(json, r'postal_code'),
        region: mapValueOfType<String>(json, r'region'),
        storeNumber: mapValueOfType<String>(json, r'store_number'),
      );
    }
    return null;
  }

  static List<TransactionLocation> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TransactionLocation>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TransactionLocation.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TransactionLocation> mapFromJson(dynamic json) {
    final map = <String, TransactionLocation>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TransactionLocation.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TransactionLocation-objects as value to a dart map
  static Map<String, List<TransactionLocation>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TransactionLocation>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TransactionLocation.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

