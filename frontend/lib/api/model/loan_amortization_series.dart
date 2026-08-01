//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LoanAmortizationSeries {
  /// Returns a new [LoanAmortizationSeries] instance.
  LoanAmortizationSeries({
    required this.accountId,
    required this.accountName,
    required this.monthsToPayOff,
    required this.monthlyPayment,
    required this.color,
    this.dataPoints = const [],
  });

  /// The ID of the loan account.
  String accountId;

  /// The name of the loan account.
  String accountName;

  /// The projected months until the loan is fully paid off.
  num monthsToPayOff;

  /// The estimated monthly payment based on the transactions.
  num monthlyPayment;

  /// Color to display with this line series
  String color;

  /// The monthly balance projection data points.
  List<HistoricalDataPoint> dataPoints;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LoanAmortizationSeries &&
    other.accountId == accountId &&
    other.accountName == accountName &&
    other.monthsToPayOff == monthsToPayOff &&
    other.monthlyPayment == monthlyPayment &&
    other.color == color &&
    _deepEquality.equals(other.dataPoints, dataPoints);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (accountId.hashCode) +
    (accountName.hashCode) +
    (monthsToPayOff.hashCode) +
    (monthlyPayment.hashCode) +
    (color.hashCode) +
    (dataPoints.hashCode);

  @override
  String toString() => 'LoanAmortizationSeries[accountId=$accountId, accountName=$accountName, monthsToPayOff=$monthsToPayOff, monthlyPayment=$monthlyPayment, color=$color, dataPoints=$dataPoints]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'accountId'] = this.accountId;
      json[r'accountName'] = this.accountName;
      json[r'monthsToPayOff'] = this.monthsToPayOff;
      json[r'monthlyPayment'] = this.monthlyPayment;
      json[r'color'] = this.color;
      json[r'dataPoints'] = this.dataPoints;
    return json;
  }

  /// Returns a new [LoanAmortizationSeries] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LoanAmortizationSeries? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'accountId'), 'Required key "LoanAmortizationSeries[accountId]" is missing from JSON.');
        assert(json[r'accountId'] != null, 'Required key "LoanAmortizationSeries[accountId]" has a null value in JSON.');
        assert(json.containsKey(r'accountName'), 'Required key "LoanAmortizationSeries[accountName]" is missing from JSON.');
        assert(json[r'accountName'] != null, 'Required key "LoanAmortizationSeries[accountName]" has a null value in JSON.');
        assert(json.containsKey(r'monthsToPayOff'), 'Required key "LoanAmortizationSeries[monthsToPayOff]" is missing from JSON.');
        assert(json[r'monthsToPayOff'] != null, 'Required key "LoanAmortizationSeries[monthsToPayOff]" has a null value in JSON.');
        assert(json.containsKey(r'monthlyPayment'), 'Required key "LoanAmortizationSeries[monthlyPayment]" is missing from JSON.');
        assert(json[r'monthlyPayment'] != null, 'Required key "LoanAmortizationSeries[monthlyPayment]" has a null value in JSON.');
        assert(json.containsKey(r'color'), 'Required key "LoanAmortizationSeries[color]" is missing from JSON.');
        assert(json[r'color'] != null, 'Required key "LoanAmortizationSeries[color]" has a null value in JSON.');
        assert(json.containsKey(r'dataPoints'), 'Required key "LoanAmortizationSeries[dataPoints]" is missing from JSON.');
        assert(json[r'dataPoints'] != null, 'Required key "LoanAmortizationSeries[dataPoints]" has a null value in JSON.');
        return true;
      }());

      return LoanAmortizationSeries(
        accountId: mapValueOfType<String>(json, r'accountId')!,
        accountName: mapValueOfType<String>(json, r'accountName')!,
        monthsToPayOff: num.parse('${json[r'monthsToPayOff']}'),
        monthlyPayment: num.parse('${json[r'monthlyPayment']}'),
        color: mapValueOfType<String>(json, r'color')!,
        dataPoints: HistoricalDataPoint.listFromJson(json[r'dataPoints']),
      );
    }
    return null;
  }

  static List<LoanAmortizationSeries> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LoanAmortizationSeries>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LoanAmortizationSeries.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LoanAmortizationSeries> mapFromJson(dynamic json) {
    final map = <String, LoanAmortizationSeries>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LoanAmortizationSeries.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LoanAmortizationSeries-objects as value to a dart map
  static Map<String, List<LoanAmortizationSeries>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LoanAmortizationSeries>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LoanAmortizationSeries.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'accountId',
    'accountName',
    'monthsToPayOff',
    'monthlyPayment',
    'color',
    'dataPoints',
  };
}

