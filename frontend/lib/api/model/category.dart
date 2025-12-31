//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Category {
  /// Returns a new [Category] instance.
  Category({
    required this.id,
    required this.name,
    this.parentCategory,
    this.icon,
    required this.type,
  });

  String id;

  /// The name of the category
  String name;

  /// The parent category this category belongs to
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Category? parentCategory;

  /// The icon to use for this category. If one is not given, we'll use the default.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? icon;

  /// If this account type should be considered an expense or income
  CategoryTypeEnum type;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Category &&
    other.id == id &&
    other.name == name &&
    other.parentCategory == parentCategory &&
    other.icon == icon &&
    other.type == type;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (parentCategory == null ? 0 : parentCategory!.hashCode) +
    (icon == null ? 0 : icon!.hashCode) +
    (type.hashCode);

  @override
  String toString() => 'Category[id=$id, name=$name, parentCategory=$parentCategory, icon=$icon, type=$type]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
    if (this.parentCategory != null) {
      json[r'parentCategory'] = this.parentCategory;
    } else {
      json[r'parentCategory'] = null;
    }
    if (this.icon != null) {
      json[r'icon'] = this.icon;
    } else {
      json[r'icon'] = null;
    }
      json[r'type'] = this.type;
    return json;
  }

  /// Returns a new [Category] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Category? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Category[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Category[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Category(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        parentCategory: Category.fromJson(json[r'parentCategory']),
        icon: mapValueOfType<String>(json, r'icon'),
        type: CategoryTypeEnum.fromJson(json[r'type'])!,
      );
    }
    return null;
  }

  static List<Category> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Category>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Category.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Category> mapFromJson(dynamic json) {
    final map = <String, Category>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Category.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Category-objects as value to a dart map
  static Map<String, List<Category>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Category>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Category.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'type',
  };
}

/// If this account type should be considered an expense or income
class CategoryTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const CategoryTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const income = CategoryTypeEnum._(r'income');
  static const expense = CategoryTypeEnum._(r'expense');

  /// List of all possible values in this [enum][CategoryTypeEnum].
  static const values = <CategoryTypeEnum>[
    income,
    expense,
  ];

  static CategoryTypeEnum? fromJson(dynamic value) => CategoryTypeEnumTypeTransformer().decode(value);

  static List<CategoryTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CategoryTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CategoryTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CategoryTypeEnum] to String,
/// and [decode] dynamic data back to [CategoryTypeEnum].
class CategoryTypeEnumTypeTransformer {
  factory CategoryTypeEnumTypeTransformer() => _instance ??= const CategoryTypeEnumTypeTransformer._();

  const CategoryTypeEnumTypeTransformer._();

  String encode(CategoryTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a CategoryTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CategoryTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'income': return CategoryTypeEnum.income;
        case r'expense': return CategoryTypeEnum.expense;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [CategoryTypeEnumTypeTransformer] instance.
  static CategoryTypeEnumTypeTransformer? _instance;
}


