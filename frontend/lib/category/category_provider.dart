import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';

/// Class that provides the store of current category info
class CategoryProvider extends BaseProvider<CategoryApi> {
  // Data store
  List<Category> _categories = [];
  final Map<String, CategoryStats> _statsCache = {};
  int _unknownCategoryCount = 0;

  // Public getters
  List<Category> get categories => _categories;
  int get unknownCategoryCount => _unknownCategoryCount;
  CategoryStats? getStatsData(int year, int? month, {int? day, Account? account}) {
    return _statsCache[generateCacheKey(year, month, day, account)];
  }

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
  Future<void> loadUpdatedCategories() async {
    await populateAndSetIfChanged(
      api.categoryControllerGetCategories,
      _categories,
      (newValue) => newValue == null ? [] : _categories = [...newValue],
    );
  }

  /// Loads updated category stats
  Future<CategoryStats?> loadCategoryStats(int year, int? month, {int? day, Account? account}) async {
    final cacheKey = generateCacheKey(year, month, day, account);
    final data = await api.categoryControllerGetCategoryStats(year, month: month, day: day, accountId: account?.id);
    if (data != null) _statsCache[cacheKey] = data;
    notifyListeners();
    return data;
  }

  Future<int?> loadUnknownCategoryCount({Account? account}) async {
    _unknownCategoryCount = await api.categoryControllerGetUnknownCategoryStats(accountId: account?.id) ?? 0;
    notifyListeners();
    return _unknownCategoryCount;
  }

  @override
  Future<void> cleanupData() async {
    _categories = [];
    _statsCache.clear();
    notifyListeners();
  }

  @override
  Future<void> onSSE(SSEData sse) async {
    super.onSSE(sse);
    if (sse.event == SSEDataEventEnum.forceUpdate) {
      cleanupData();
    }
  }
}
