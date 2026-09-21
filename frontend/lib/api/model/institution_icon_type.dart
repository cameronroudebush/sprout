//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// The asset variant variant to request from Brandfetch (icon or symbol)
class InstitutionIconType {
  /// Instantiate a new enum with the provided [value].
  const InstitutionIconType._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const icon = InstitutionIconType._(r'icon');
  static const symbol = InstitutionIconType._(r'symbol');

  /// List of all possible values in this [enum][InstitutionIconType].
  static const values = <InstitutionIconType>[
    icon,
    symbol,
  ];

  static InstitutionIconType? fromJson(dynamic value) => InstitutionIconTypeTypeTransformer().decode(value);

  static List<InstitutionIconType> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InstitutionIconType>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InstitutionIconType.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [InstitutionIconType] to String,
/// and [decode] dynamic data back to [InstitutionIconType].
class InstitutionIconTypeTypeTransformer {
  factory InstitutionIconTypeTypeTransformer() => _instance ??= const InstitutionIconTypeTypeTransformer._();

  const InstitutionIconTypeTypeTransformer._();

  String encode(InstitutionIconType data) => data.value;

  /// Decodes a [dynamic value][data] to a InstitutionIconType.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  InstitutionIconType? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'icon': return InstitutionIconType.icon;
        case r'symbol': return InstitutionIconType.symbol;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [InstitutionIconTypeTypeTransformer] instance.
  static InstitutionIconTypeTypeTransformer? _instance;
}

