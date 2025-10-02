/// An enum to represent the fixed types of a category.
enum CategoryType {
  income,
  expense;

  static CategoryType fromString(String type) {
    if (type == 'income') {
      return CategoryType.income;
    }
    if (type == 'expense') {
      return CategoryType.expense;
    }
    throw Exception('Invalid CategoryType string: $type');
  }
}

/// A class representing a category of a transaction
class Category {
  final String id;
  final String name;
  final CategoryType type;
  final Category? parentCategory;

  const Category({required this.id, required this.name, required this.type, this.parentCategory});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CategoryType.fromString(json['type'] as String),
      parentCategory: json['parentCategory'] != null ? Category.fromJson(json['parentCategory']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'parentCategory': parentCategory?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) => other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
