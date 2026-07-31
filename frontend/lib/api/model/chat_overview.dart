//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChatOverview {
  /// Returns a new [ChatOverview] instance.
  ChatOverview({
    required this.id,
    required this.type,
    required this.time,
    required this.text,
  });

  String id;

  ChatOverviewTypeEnum type;

  DateTime time;

  String text;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChatOverview &&
    other.id == id &&
    other.type == type &&
    other.time == time &&
    other.text == text;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (type.hashCode) +
    (time.hashCode) +
    (text.hashCode);

  @override
  String toString() => 'ChatOverview[id=$id, type=$type, time=$time, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'type'] = this.type;
      json[r'time'] = this.time.toUtc().toIso8601String();
      json[r'text'] = this.text;
    return json;
  }

  /// Returns a new [ChatOverview] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChatOverview? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ChatOverview[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ChatOverview[id]" has a null value in JSON.');
        assert(json.containsKey(r'type'), 'Required key "ChatOverview[type]" is missing from JSON.');
        assert(json[r'type'] != null, 'Required key "ChatOverview[type]" has a null value in JSON.');
        assert(json.containsKey(r'time'), 'Required key "ChatOverview[time]" is missing from JSON.');
        assert(json[r'time'] != null, 'Required key "ChatOverview[time]" has a null value in JSON.');
        assert(json.containsKey(r'text'), 'Required key "ChatOverview[text]" is missing from JSON.');
        assert(json[r'text'] != null, 'Required key "ChatOverview[text]" has a null value in JSON.');
        return true;
      }());

      return ChatOverview(
        id: mapValueOfType<String>(json, r'id')!,
        type: ChatOverviewTypeEnum.fromJson(json[r'type'])!,
        time: mapDateTime(json, r'time', r'')!,
        text: mapValueOfType<String>(json, r'text')!,
      );
    }
    return null;
  }

  static List<ChatOverview> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChatOverview>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChatOverview.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChatOverview> mapFromJson(dynamic json) {
    final map = <String, ChatOverview>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChatOverview.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChatOverview-objects as value to a dart map
  static Map<String, List<ChatOverview>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChatOverview>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChatOverview.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'type',
    'time',
    'text',
  };
}

