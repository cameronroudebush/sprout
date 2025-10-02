import 'package:sprout/category/models/category.dart';
import 'package:sprout/category/models/category_stats.dart';
import 'package:sprout/core/api/base.dart';

/// Class that provides callable endpoints for the categories of transactions
class CategoryAPI extends BaseAPI {
  CategoryAPI(super.client);

  /// Gets categories
  Future<List<Category>> get() async {
    final endpoint = "/category";
    final result = await client.get(endpoint) as List<dynamic>;
    return (result).map((e) => Category.fromJson(e)).toList();
  }

  /// Gets the stats for our category information for the last N days
  Future<CategoryStats> getStats({int days = 30}) async {
    final endpoint = "/category/stats";
    final body = {'days': days};
    final result = await client.post(body, endpoint) as dynamic;
    return CategoryStats.fromJson(result);
  }

  /// Adds the given category via the API
  Future<Category> add(Category rule) async {
    final endpoint = "/category/add";
    final body = rule.toJson();
    final result = await client.post(body, endpoint) as dynamic;
    return Category.fromJson(result);
  }

  /// Deletes the given category via the API
  Future<Category> delete(Category rule) async {
    final endpoint = "/category/delete";
    final body = rule.toJson();
    final result = await client.post(body, endpoint) as dynamic;
    return Category.fromJson(result);
  }

  /// Edits the given category via the API
  Future<Category> edit(Category rule) async {
    final endpoint = "/category/edit";
    final body = rule.toJson();
    final result = await client.post(body, endpoint) as dynamic;
    return Category.fromJson(result);
  }
}
