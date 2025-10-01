import 'package:sprout/category/api.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/transaction/models/category.dart';
import 'package:sprout/transaction/models/category_stats.dart';

/// Class that provides the store of current category info
class CategoryProvider extends BaseProvider<CategoryAPI> {
  // Data store
  List<Category> _categories = [];
  CategoryStats? _categoryStats;

  // Public getters
  List<Category> get categories => _categories;
  CategoryStats? get categoryStats => _categoryStats;

  CategoryProvider(super.api);

  Future<List<Category>> populateCategories() async {
    return _categories = await api.get();
  }

  Future<CategoryStats> populateCategoryStats() async {
    return _categoryStats = await api.getStats();
  }

  /// Uses the API to add the given category
  Future<Category> add(Category c) async {
    notifyListeners();
    final newCategory = await api.add(c);
    _categories.add(newCategory);
    notifyListeners();
    return newCategory;
  }

  /// Uses the API to delete the given category
  Future<Category> delete(Category c) async {
    notifyListeners();
    final deletedCategory = await api.delete(c);
    _categories.removeWhere((r) => r.id == deletedCategory.id);
    notifyListeners();
    return deletedCategory;
  }

  @override
  Future<void> updateData() async {
    isLoading = true;
    notifyListeners();
    await populateCategories();
    await populateCategoryStats();
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> cleanupData() async {
    _categories = [];
    _categoryStats = null;
    notifyListeners();
  }
}
