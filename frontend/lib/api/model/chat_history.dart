//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChatHistory {
  /// Returns a new [ChatHistory] instance.
  ChatHistory({
    required this.id,
    required this.role,
    required this.time,
    required this.text,
    required this.isThinking,
  });

  String id;

  /// Who said the message, either the LLM (AI) or the user.
  ChatHistoryRoleEnum role;

  /// The time the chat occurred on
  DateTime time;

  /// The text of the chat
  String text;

  /// If the model is still thinking of a response for this one
  bool isThinking;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChatHistory &&
    other.id == id &&
    other.role == role &&
    other.time == time &&
    other.text == text &&
    other.isThinking == isThinking;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (role.hashCode) +
    (time.hashCode) +
    (text.hashCode) +
    (isThinking.hashCode);

  @override
  String toString() => 'ChatHistory[id=$id, role=$role, time=$time, text=$text, isThinking=$isThinking]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'role'] = this.role;
      json[r'time'] = this.time.toUtc().toIso8601String();
      json[r'text'] = this.text;
      json[r'isThinking'] = this.isThinking;
    return json;
  }

  /// Returns a new [ChatHistory] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChatHistory? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ChatHistory[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ChatHistory[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ChatHistory(
        id: mapValueOfType<String>(json, r'id')!,
        role: ChatHistoryRoleEnum.fromJson(json[r'role'])!,
        time: mapDateTime(json, r'time', r'')!,
        text: mapValueOfType<String>(json, r'text')!,
        isThinking: mapValueOfType<bool>(json, r'isThinking')!,
      );
    }
    return null;
  }

  static List<ChatHistory> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChatHistory>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChatHistory.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChatHistory> mapFromJson(dynamic json) {
    final map = <String, ChatHistory>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChatHistory.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChatHistory-objects as value to a dart map
  static Map<String, List<ChatHistory>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChatHistory>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChatHistory.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'role',
    'time',
    'text',
    'isThinking',
  };
}

/// Who said the message, either the LLM (AI) or the user.
class ChatHistoryRoleEnum {
  /// Instantiate a new enum with the provided [value].
  const ChatHistoryRoleEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const user = ChatHistoryRoleEnum._(r'user');
  static const model = ChatHistoryRoleEnum._(r'model');

  /// List of all possible values in this [enum][ChatHistoryRoleEnum].
  static const values = <ChatHistoryRoleEnum>[
    user,
    model,
  ];

  static ChatHistoryRoleEnum? fromJson(dynamic value) => ChatHistoryRoleEnumTypeTransformer().decode(value);

  static List<ChatHistoryRoleEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChatHistoryRoleEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChatHistoryRoleEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ChatHistoryRoleEnum] to String,
/// and [decode] dynamic data back to [ChatHistoryRoleEnum].
class ChatHistoryRoleEnumTypeTransformer {
  factory ChatHistoryRoleEnumTypeTransformer() => _instance ??= const ChatHistoryRoleEnumTypeTransformer._();

  const ChatHistoryRoleEnumTypeTransformer._();

  String encode(ChatHistoryRoleEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ChatHistoryRoleEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ChatHistoryRoleEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'user': return ChatHistoryRoleEnum.user;
        case r'model': return ChatHistoryRoleEnum.model;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ChatHistoryRoleEnumTypeTransformer] instance.
  static ChatHistoryRoleEnumTypeTransformer? _instance;
}


