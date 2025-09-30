/// A class representing the statistics for categories.
class CategoryStats {
  /// The number of transactions matching to each category.
  final Map<String, int> categoryCount;

  CategoryStats({required this.categoryCount});

  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    return CategoryStats(categoryCount: Map<String, int>.from(json['categoryCount'] as Map));
  }
}
