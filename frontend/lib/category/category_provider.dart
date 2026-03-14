import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/sse_provider.dart';

part "category_provider.g.dart";

@Riverpod(keepAlive: true)
Future<CategoryApi> categoryApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return CategoryApi(client);
}

@Riverpod(keepAlive: true)
class Categories extends _$Categories {
  @override
  Future<List<Category>> build() async {
    // Listen for SSE force updates to refresh the list
    ref.listen(sseProvider, (prev, next) {
      final event = next.latestData?.event;
      if (event == SSEDataEventEnum.forceUpdate) {
        ref.invalidateSelf();
      }
    });

    final api = await ref.watch(categoryApiProvider.future);
    return await api.categoryControllerGetCategories() ?? [];
  }

  Future<Category?> add(Category c) async {
    final api = await ref.read(categoryApiProvider.future);
    final newCategory = await api.categoryControllerCreate(c);
    if (newCategory != null) {
      ref.invalidateSelf();
    }
    return newCategory;
  }

  Future<void> delete(String id) async {
    final api = await ref.read(categoryApiProvider.future);
    await api.categoryControllerDelete(id);
    ref.invalidateSelf();
  }

  Future<Category?> edit(Category c) async {
    final api = await ref.read(categoryApiProvider.future);
    final updated = await api.categoryControllerEdit(c.id, c);
    if (updated != null) {
      ref.invalidateSelf();
    }
    return updated;
  }
}

/// Tracks the state for the unknown category count
@Riverpod(keepAlive: true)
class UnknownCategoryCount extends _$UnknownCategoryCount {
  @override
  Future<int> build([String? accountId]) async {
    ref.listen(sseProvider, (prev, next) {
      final event = next.latestData?.event;
      if (event == SSEDataEventEnum.forceUpdate) {
        ref.invalidateSelf();
      }
    });

    final api = await ref.watch(categoryApiProvider.future);
    return await api.categoryControllerGetUnknownCategoryStats(accountId: accountId) ?? 0;
  }

  Future<void> refresh() async => ref.invalidateSelf();
}
