import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';

/// Class that provides the store of current category info
class CategoryProvider extends BaseProvider<CategoryApi> {
  // Data store
  List<Category> _categories = [];
  CategoryStats? _categoryStats;

  // Public getters
  List<Category> get categories => _categories;
  CategoryStats? get categoryStats => _categoryStats;

  CategoryProvider(super.api);

  Future<List<Category>> populateCategories() async {
    return _categories = (await api.categoryControllerGetCategories()) ?? [];
  }

  Future<CategoryStats?> populateCategoryStats({int days = 30}) async {
    return _categoryStats = await api.categoryControllerGetCategoryStats(days);
  }

  /// Uses the API to add the given category
  Future<Category?> add(Category c) async {
    notifyListeners();
    final newCategory = await api.categoryControllerCreate(c);
    if (newCategory != null) _categories.add(newCategory);
    notifyListeners();
    return newCategory;
  }

  /// Uses the API to delete the given category
  Future<Category> delete(Category c) async {
    notifyListeners();
    await api.categoryControllerDelete(c.id);
    _categories.removeWhere((r) => r.id == c.id);
    notifyListeners();
    return c;
  }

  Future<Category> edit(Category c) async {
    notifyListeners();
    final updatedCategory = (await api.categoryControllerEdit(c.id, c))!;
    final index = _categories.indexWhere((r) => r.id == updatedCategory.id);
    if (index != -1) _categories[index] = updatedCategory;
    notifyListeners();
    return updatedCategory;
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
