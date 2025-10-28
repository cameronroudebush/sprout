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

  /// Loads updated category information, also updates loading status
  Future<void> loadUpdatedCategories(bool showLoaders) async {
    final shouldSetLoadingStats = _categories.isEmpty || showLoaders;
    if (shouldSetLoadingStats) setLoadingStatus(true);
    await populateAndSetIfChanged(
      api.categoryControllerGetCategories,
      _categories,
      (newValue) => _categories = newValue ?? [],
    );
    if (shouldSetLoadingStats) setLoadingStatus(false);
  }

  /// Loads updated category stats
  Future<void> loadCategoryStats(bool showLoaders, {int days = 30}) async {
    final shouldSetLoadingStats = _categoryStats == null || showLoaders;
    if (shouldSetLoadingStats) setLoadingStatus(true);
    await populateAndSetIfChanged(
      () => api.categoryControllerGetCategoryStats(days),
      _categoryStats,
      (newValue) => _categoryStats = newValue,
    );
    if (shouldSetLoadingStats) setLoadingStatus(false);
  }

  @override
  Future<void> cleanupData() async {
    _categories = [];
    _categoryStats = null;
    notifyListeners();
  }
}
