//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SankeyData {
  /// Returns a new [SankeyData] instance.
  SankeyData({
    this.colors = const {},
    this.nodes = const [],
    this.links = const [],
  });

  Map<String, String> colors;

  List<String> nodes;

  List<SankeyLink> links;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SankeyData &&
    _deepEquality.equals(other.colors, colors) &&
    _deepEquality.equals(other.nodes, nodes) &&
    _deepEquality.equals(other.links, links);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (colors.hashCode) +
    (nodes.hashCode) +
    (links.hashCode);

  @override
  String toString() => 'SankeyData[colors=$colors, nodes=$nodes, links=$links]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'colors'] = this.colors;
      json[r'nodes'] = this.nodes;
      json[r'links'] = this.links;
    return json;
  }

  /// Returns a new [SankeyData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SankeyData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SankeyData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SankeyData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SankeyData(
        colors: mapCastOfType<String, String>(json, r'colors')!,
        nodes: json[r'nodes'] is Iterable
            ? (json[r'nodes'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        links: SankeyLink.listFromJson(json[r'links']),
      );
    }
    return null;
  }

  static List<SankeyData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SankeyData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SankeyData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SankeyData> mapFromJson(dynamic json) {
    final map = <String, SankeyData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SankeyData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SankeyData-objects as value to a dart map
  static Map<String, List<SankeyData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SankeyData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SankeyData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'colors',
    'nodes',
    'links',
  };
}

