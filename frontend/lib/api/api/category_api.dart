//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class CategoryApi {
  CategoryApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Creates a new category.
  ///
  /// Creates a new category that can be used for transactions to associate to.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [Category] category (required):
  Future<Response> categoryControllerCreateWithHttpInfo(Category category,) async {
    // ignore: prefer_const_declarations
    final path = r'/category';

    // ignore: prefer_final_locals
    Object? postBody = category;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Creates a new category.
  ///
  /// Creates a new category that can be used for transactions to associate to.
  ///
  /// Parameters:
  ///
  /// * [Category] category (required):
  Future<Category?> categoryControllerCreate(Category category,) async {
    final response = await categoryControllerCreateWithHttpInfo(category,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Category',) as Category;
    
    }
    return null;
  }

  /// Delete category by ID.
  ///
  /// Deletes a category by the given ID and updates references to it to reset them.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> categoryControllerDeleteWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/category/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Delete category by ID.
  ///
  /// Deletes a category by the given ID and updates references to it to reset them.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<void> categoryControllerDelete(String id,) async {
    final response = await categoryControllerDeleteWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Edit category.
  ///
  /// Edits a category by the given ID.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [Category] category (required):
  Future<Response> categoryControllerEditWithHttpInfo(String id, Category category,) async {
    // ignore: prefer_const_declarations
    final path = r'/category/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = category;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Edit category.
  ///
  /// Edits a category by the given ID.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [Category] category (required):
  Future<Category?> categoryControllerEdit(String id, Category category,) async {
    final response = await categoryControllerEditWithHttpInfo(id, category,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Category',) as Category;
    
    }
    return null;
  }

  /// Get categories.
  ///
  /// Retrieves all categories for the authenticated user.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> categoryControllerGetCategoriesWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/category';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get categories.
  ///
  /// Retrieves all categories for the authenticated user.
  Future<List<Category>?> categoryControllerGetCategories() async {
    final response = await categoryControllerGetCategoriesWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Category>') as List)
        .cast<Category>()
        .toList(growable: false);

    }
    return null;
  }

  /// Gets category stats.
  ///
  /// Retrieves all categories for the authenticated user with the total number of transactions per category for the given query.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [num] year (required):
  ///   The year we want the stats for.
  ///
  /// * [num] month:
  ///   The month we want the stats for. If not given, assumes we want the whole year.
  ///
  /// * [num] day:
  ///   The day we want the stats for. If not given, assumes to include the entire month. If the month is not included in your query, this is ignored.
  ///
  /// * [String] accountId:
  ///   The ID of the account to retrieve transactions from.
  Future<Response> categoryControllerGetCategoryStatsWithHttpInfo(num year, { num? month, num? day, String? accountId, }) async {
    // ignore: prefer_const_declarations
    final path = r'/category/stats';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'year', year));
    if (month != null) {
      queryParams.addAll(_queryParams('', 'month', month));
    }
    if (day != null) {
      queryParams.addAll(_queryParams('', 'day', day));
    }
    if (accountId != null) {
      queryParams.addAll(_queryParams('', 'accountId', accountId));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Gets category stats.
  ///
  /// Retrieves all categories for the authenticated user with the total number of transactions per category for the given query.
  ///
  /// Parameters:
  ///
  /// * [num] year (required):
  ///   The year we want the stats for.
  ///
  /// * [num] month:
  ///   The month we want the stats for. If not given, assumes we want the whole year.
  ///
  /// * [num] day:
  ///   The day we want the stats for. If not given, assumes to include the entire month. If the month is not included in your query, this is ignored.
  ///
  /// * [String] accountId:
  ///   The ID of the account to retrieve transactions from.
  Future<CategoryStats?> categoryControllerGetCategoryStats(num year, { num? month, num? day, String? accountId, }) async {
    final response = await categoryControllerGetCategoryStatsWithHttpInfo(year,  month: month, day: day, accountId: accountId, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CategoryStats',) as CategoryStats;
    
    }
    return null;
  }

  /// Gets unknown category stats.
  ///
  /// Retrieves the count of transactions with unknown categories for the authenticated user. This includes all possible transactions.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] accountId:
  ///   The ID of the account to retrieve transactions from.
  Future<Response> categoryControllerGetUnknownCategoryStatsWithHttpInfo({ String? accountId, }) async {
    // ignore: prefer_const_declarations
    final path = r'/category/stats/unknown';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (accountId != null) {
      queryParams.addAll(_queryParams('', 'accountId', accountId));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Gets unknown category stats.
  ///
  /// Retrieves the count of transactions with unknown categories for the authenticated user. This includes all possible transactions.
  ///
  /// Parameters:
  ///
  /// * [String] accountId:
  ///   The ID of the account to retrieve transactions from.
  Future<int?> categoryControllerGetUnknownCategoryStats({ String? accountId, }) async {
    final response = await categoryControllerGetUnknownCategoryStatsWithHttpInfo( accountId: accountId, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'int',) as int;
    
    }
    return null;
  }
}
