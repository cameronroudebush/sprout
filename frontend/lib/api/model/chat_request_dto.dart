//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChatRequestDTO {
  /// Returns a new [ChatRequestDTO] instance.
  ChatRequestDTO({
    required this.message,
    this.timeframe = const ChatRequestDTOTimeframeEnum._('threeMonths'),
  });

  /// The message to send to the AI
  String message;

  /// The historical timeframe to include in context.
  ChatRequestDTOTimeframeEnum timeframe;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChatRequestDTO &&
    other.message == message &&
    other.timeframe == timeframe;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (message.hashCode) +
    (timeframe.hashCode);

  @override
  String toString() => 'ChatRequestDTO[message=$message, timeframe=$timeframe]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'message'] = this.message;
      json[r'timeframe'] = this.timeframe;
    return json;
  }

  /// Returns a new [ChatRequestDTO] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChatRequestDTO? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'message'), 'Required key "ChatRequestDTO[message]" is missing from JSON.');
        assert(json[r'message'] != null, 'Required key "ChatRequestDTO[message]" has a null value in JSON.');
        assert(json.containsKey(r'timeframe'), 'Required key "ChatRequestDTO[timeframe]" is missing from JSON.');
        assert(json[r'timeframe'] != null, 'Required key "ChatRequestDTO[timeframe]" has a null value in JSON.');
        return true;
      }());

      return ChatRequestDTO(
        message: mapValueOfType<String>(json, r'message')!,
        timeframe: ChatRequestDTOTimeframeEnum.fromJson(json[r'timeframe'])!,
      );
    }
    return null;
  }

  static List<ChatRequestDTO> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChatRequestDTO>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChatRequestDTO.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChatRequestDTO> mapFromJson(dynamic json) {
    final map = <String, ChatRequestDTO>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChatRequestDTO.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChatRequestDTO-objects as value to a dart map
  static Map<String, List<ChatRequestDTO>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChatRequestDTO>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChatRequestDTO.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'message',
    'timeframe',
  };
}

/// The historical timeframe to include in context.
class ChatRequestDTOTimeframeEnum {
  /// Instantiate a new enum with the provided [value].
  const ChatRequestDTOTimeframeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const threeMonths = ChatRequestDTOTimeframeEnum._(r'threeMonths');
  static const sixMonths = ChatRequestDTOTimeframeEnum._(r'sixMonths');
  static const oneYear = ChatRequestDTOTimeframeEnum._(r'oneYear');

  /// List of all possible values in this [enum][ChatRequestDTOTimeframeEnum].
  static const values = <ChatRequestDTOTimeframeEnum>[
    threeMonths,
    sixMonths,
    oneYear,
  ];

  static ChatRequestDTOTimeframeEnum? fromJson(dynamic value) => ChatRequestDTOTimeframeEnumTypeTransformer().decode(value);

  static List<ChatRequestDTOTimeframeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChatRequestDTOTimeframeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChatRequestDTOTimeframeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ChatRequestDTOTimeframeEnum] to String,
/// and [decode] dynamic data back to [ChatRequestDTOTimeframeEnum].
class ChatRequestDTOTimeframeEnumTypeTransformer {
  factory ChatRequestDTOTimeframeEnumTypeTransformer() => _instance ??= const ChatRequestDTOTimeframeEnumTypeTransformer._();

  const ChatRequestDTOTimeframeEnumTypeTransformer._();

  String encode(ChatRequestDTOTimeframeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ChatRequestDTOTimeframeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ChatRequestDTOTimeframeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'threeMonths': return ChatRequestDTOTimeframeEnum.threeMonths;
        case r'sixMonths': return ChatRequestDTOTimeframeEnum.sixMonths;
        case r'oneYear': return ChatRequestDTOTimeframeEnum.oneYear;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ChatRequestDTOTimeframeEnumTypeTransformer] instance.
  static ChatRequestDTOTimeframeEnumTypeTransformer? _instance;
}


