//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// How often the user should receive email updates.
class EmailUpdateFrequencyEnum {
  /// Instantiate a new enum with the provided [value].
  const EmailUpdateFrequencyEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const none = EmailUpdateFrequencyEnum._(r'none');
  static const weekly = EmailUpdateFrequencyEnum._(r'weekly');

  /// List of all possible values in this [enum][EmailUpdateFrequencyEnum].
  static const values = <EmailUpdateFrequencyEnum>[
    none,
    weekly,
  ];

  static EmailUpdateFrequencyEnum? fromJson(dynamic value) => EmailUpdateFrequencyEnumTypeTransformer().decode(value);

  static List<EmailUpdateFrequencyEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EmailUpdateFrequencyEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EmailUpdateFrequencyEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [EmailUpdateFrequencyEnum] to String,
/// and [decode] dynamic data back to [EmailUpdateFrequencyEnum].
class EmailUpdateFrequencyEnumTypeTransformer {
  factory EmailUpdateFrequencyEnumTypeTransformer() => _instance ??= const EmailUpdateFrequencyEnumTypeTransformer._();

  const EmailUpdateFrequencyEnumTypeTransformer._();

  String encode(EmailUpdateFrequencyEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a EmailUpdateFrequencyEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  EmailUpdateFrequencyEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'none': return EmailUpdateFrequencyEnum.none;
        case r'weekly': return EmailUpdateFrequencyEnum.weekly;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [EmailUpdateFrequencyEnumTypeTransformer] instance.
  static EmailUpdateFrequencyEnumTypeTransformer? _instance;
}

