//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MajorIndexTimelineDto {
  /// Returns a new [MajorIndexTimelineDto] instance.
  MajorIndexTimelineDto({
    required this.symbol,
    required this.name,
    required this.color,
    this.timeline = const [],
  });

  /// The official Yahoo Finance ticker index symbol code.
  String symbol;

  /// The readable corporate clean name matching the index symbol.
  String name;

  /// The hexadecimal color token string representing this brand asset.
  String color;

  /// The historical performance point ledger tracking both raw price and performance percentages.
  List<MajorIndexTimelinePoint> timeline;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MajorIndexTimelineDto &&
    other.symbol == symbol &&
    other.name == name &&
    other.color == color &&
    _deepEquality.equals(other.timeline, timeline);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (symbol.hashCode) +
    (name.hashCode) +
    (color.hashCode) +
    (timeline.hashCode);

  @override
  String toString() => 'MajorIndexTimelineDto[symbol=$symbol, name=$name, color=$color, timeline=$timeline]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'symbol'] = this.symbol;
      json[r'name'] = this.name;
      json[r'color'] = this.color;
      json[r'timeline'] = this.timeline;
    return json;
  }

  /// Returns a new [MajorIndexTimelineDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MajorIndexTimelineDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'symbol'), 'Required key "MajorIndexTimelineDto[symbol]" is missing from JSON.');
        assert(json[r'symbol'] != null, 'Required key "MajorIndexTimelineDto[symbol]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "MajorIndexTimelineDto[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "MajorIndexTimelineDto[name]" has a null value in JSON.');
        assert(json.containsKey(r'color'), 'Required key "MajorIndexTimelineDto[color]" is missing from JSON.');
        assert(json[r'color'] != null, 'Required key "MajorIndexTimelineDto[color]" has a null value in JSON.');
        assert(json.containsKey(r'timeline'), 'Required key "MajorIndexTimelineDto[timeline]" is missing from JSON.');
        assert(json[r'timeline'] != null, 'Required key "MajorIndexTimelineDto[timeline]" has a null value in JSON.');
        return true;
      }());

      return MajorIndexTimelineDto(
        symbol: mapValueOfType<String>(json, r'symbol')!,
        name: mapValueOfType<String>(json, r'name')!,
        color: mapValueOfType<String>(json, r'color')!,
        timeline: MajorIndexTimelinePoint.listFromJson(json[r'timeline']),
      );
    }
    return null;
  }

  static List<MajorIndexTimelineDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MajorIndexTimelineDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MajorIndexTimelineDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MajorIndexTimelineDto> mapFromJson(dynamic json) {
    final map = <String, MajorIndexTimelineDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MajorIndexTimelineDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MajorIndexTimelineDto-objects as value to a dart map
  static Map<String, List<MajorIndexTimelineDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MajorIndexTimelineDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MajorIndexTimelineDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'symbol',
    'name',
    'color',
    'timeline',
  };
}

