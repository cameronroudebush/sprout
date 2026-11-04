//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PortfolioSummaryDto {
  /// Returns a new [PortfolioSummaryDto] instance.
  PortfolioSummaryDto({
    required this.totalValue,
    required this.dayChange,
    required this.dayChangePercent,
  });

  /// Total current market value of the user's portfolio in their configured currency.
  num totalValue;

  /// Estimated portfolio value change since the previous market close.
  num dayChange;

  /// Estimated portfolio percentage change since the previous market close.
  num dayChangePercent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioSummaryDto &&
          other.totalValue == totalValue &&
          other.dayChange == dayChange &&
          other.dayChangePercent == dayChangePercent;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (totalValue.hashCode) +
      (dayChange.hashCode) +
      (dayChangePercent.hashCode);

  @override
  String toString() =>
      'PortfolioSummaryDto[totalValue=$totalValue, dayChange=$dayChange, dayChangePercent=$dayChangePercent]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'totalValue'] = this.totalValue;
    json[r'dayChange'] = this.dayChange;
    json[r'dayChangePercent'] = this.dayChangePercent;
    return json;
  }

  /// Returns a new [PortfolioSummaryDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PortfolioSummaryDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'totalValue'),
            'Required key "PortfolioSummaryDto[totalValue]" is missing from JSON.');
        assert(json[r'totalValue'] != null,
            'Required key "PortfolioSummaryDto[totalValue]" has a null value in JSON.');
        assert(json.containsKey(r'dayChange'),
            'Required key "PortfolioSummaryDto[dayChange]" is missing from JSON.');
        assert(json[r'dayChange'] != null,
            'Required key "PortfolioSummaryDto[dayChange]" has a null value in JSON.');
        assert(json.containsKey(r'dayChangePercent'),
            'Required key "PortfolioSummaryDto[dayChangePercent]" is missing from JSON.');
        assert(json[r'dayChangePercent'] != null,
            'Required key "PortfolioSummaryDto[dayChangePercent]" has a null value in JSON.');
        return true;
      }());

      return PortfolioSummaryDto(
        totalValue: num.parse('${json[r'totalValue']}'),
        dayChange: num.parse('${json[r'dayChange']}'),
        dayChangePercent: num.parse('${json[r'dayChangePercent']}'),
      );
    }
    return null;
  }

  static List<PortfolioSummaryDto> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <PortfolioSummaryDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PortfolioSummaryDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PortfolioSummaryDto> mapFromJson(dynamic json) {
    final map = <String, PortfolioSummaryDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PortfolioSummaryDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PortfolioSummaryDto-objects as value to a dart map
  static Map<String, List<PortfolioSummaryDto>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<PortfolioSummaryDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PortfolioSummaryDto.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'totalValue',
    'dayChange',
    'dayChangePercent',
  };
}
