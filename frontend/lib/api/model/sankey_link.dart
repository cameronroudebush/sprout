//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SankeyLink {
  /// Returns a new [SankeyLink] instance.
  SankeyLink({
    required this.source_,
    required this.target,
    required this.value,
    this.description,
  });

  String source_;

  String target;

  num value;

  /// A way to help describe what this link is
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SankeyLink &&
    other.source_ == source_ &&
    other.target == target &&
    other.value == value &&
    other.description == description;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (source_.hashCode) +
    (target.hashCode) +
    (value.hashCode) +
    (description == null ? 0 : description!.hashCode);

  @override
  String toString() => 'SankeyLink[source_=$source_, target=$target, value=$value, description=$description]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'source'] = this.source_;
      json[r'target'] = this.target;
      json[r'value'] = this.value;
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    return json;
  }

  /// Returns a new [SankeyLink] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SankeyLink? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SankeyLink[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SankeyLink[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SankeyLink(
        source_: mapValueOfType<String>(json, r'source')!,
        target: mapValueOfType<String>(json, r'target')!,
        value: num.parse('${json[r'value']}'),
        description: mapValueOfType<String>(json, r'description'),
      );
    }
    return null;
  }

  static List<SankeyLink> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SankeyLink>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SankeyLink.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SankeyLink> mapFromJson(dynamic json) {
    final map = <String, SankeyLink>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SankeyLink.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SankeyLink-objects as value to a dart map
  static Map<String, List<SankeyLink>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SankeyLink>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SankeyLink.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'source',
    'target',
    'value',
  };
}

