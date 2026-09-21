//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class BudgetApi {
  BudgetApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create a new category budget.
  ///
  /// Creates a new monthly budget target for a category.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateBudgetDto] createBudgetDto (required):
  Future<Response> budgetControllerCreateBudgetWithHttpInfo(CreateBudgetDto createBudgetDto, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/budget';

    // ignore: prefer_final_locals
    Object? postBody = createBudgetDto;

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
      abortTrigger: abortTrigger,
    );
  }

  /// Create a new category budget.
  ///
  /// Creates a new monthly budget target for a category.
  ///
  /// Parameters:
  ///
  /// * [CreateBudgetDto] createBudgetDto (required):
  Future<Budget?> budgetControllerCreateBudget(CreateBudgetDto createBudgetDto, { Future<void>? abortTrigger, }) async {
    final response = await budgetControllerCreateBudgetWithHttpInfo(createBudgetDto, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Budget',) as Budget;

    }
    return null;
  }

  /// Delete a budget target.
  ///
  /// Deletes an existing category budget target.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> budgetControllerDeleteBudgetWithHttpInfo(String id, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/budget/{id}'
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
      abortTrigger: abortTrigger,
    );
  }

  /// Delete a budget target.
  ///
  /// Deletes an existing category budget target.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<void> budgetControllerDeleteBudget(String id, { Future<void>? abortTrigger, }) async {
    final response = await budgetControllerDeleteBudgetWithHttpInfo(id, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get all user budgets.
  ///
  /// Retrieves all configured budget targets for the current user.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> budgetControllerGetAllBudgetsWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/budget';

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
      abortTrigger: abortTrigger,
    );
  }

  /// Get all user budgets.
  ///
  /// Retrieves all configured budget targets for the current user.
  Future<List<Budget>?> budgetControllerGetAllBudgets({ Future<void>? abortTrigger, }) async {
    final response = await budgetControllerGetAllBudgetsWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Budget>') as List)
        .cast<Budget>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get historical budget performance.
  ///
  /// Retrieves historical monthly performance looking backwards in time.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] categoryId:
  ///   Filter history to a specific category.
  ///
  /// * [num] months:
  ///   Number of months to look back (default 6).
  Future<Response> budgetControllerGetBudgetHistoryWithHttpInfo({ String? categoryId, num? months, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/budget/history';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (categoryId != null) {
      queryParams.addAll(_queryParams('', 'categoryId', categoryId));
    }
    if (months != null) {
      queryParams.addAll(_queryParams('', 'months', months));
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
      abortTrigger: abortTrigger,
    );
  }

  /// Get historical budget performance.
  ///
  /// Retrieves historical monthly performance looking backwards in time.
  ///
  /// Parameters:
  ///
  /// * [String] categoryId:
  ///   Filter history to a specific category.
  ///
  /// * [num] months:
  ///   Number of months to look back (default 6).
  Future<BudgetHistoryResponseDto?> budgetControllerGetBudgetHistory({ String? categoryId, num? months, Future<void>? abortTrigger, }) async {
    final response = await budgetControllerGetBudgetHistoryWithHttpInfo(categoryId: categoryId, months: months, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'BudgetHistoryResponseDto',) as BudgetHistoryResponseDto;

    }
    return null;
  }

  /// Get budget overview.
  ///
  /// Retrieves budget targets vs actual spending breakdown for a given month and year.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [num] year:
  ///
  /// * [num] month:
  Future<Response> budgetControllerGetBudgetOverviewWithHttpInfo({ num? year, num? month, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/budget/overview';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (year != null) {
      queryParams.addAll(_queryParams('', 'year', year));
    }
    if (month != null) {
      queryParams.addAll(_queryParams('', 'month', month));
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
      abortTrigger: abortTrigger,
    );
  }

  /// Get budget overview.
  ///
  /// Retrieves budget targets vs actual spending breakdown for a given month and year.
  ///
  /// Parameters:
  ///
  /// * [num] year:
  ///
  /// * [num] month:
  Future<BudgetOverviewResponseDto?> budgetControllerGetBudgetOverview({ num? year, num? month, Future<void>? abortTrigger, }) async {
    final response = await budgetControllerGetBudgetOverviewWithHttpInfo(year: year, month: month, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'BudgetOverviewResponseDto',) as BudgetOverviewResponseDto;

    }
    return null;
  }

  /// Update a budget target.
  ///
  /// Updates an existing budget target's monthly amount.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpdateBudgetDto] updateBudgetDto (required):
  Future<Response> budgetControllerUpdateBudgetWithHttpInfo(String id, UpdateBudgetDto updateBudgetDto, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/budget/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = updateBudgetDto;

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
      abortTrigger: abortTrigger,
    );
  }

  /// Update a budget target.
  ///
  /// Updates an existing budget target's monthly amount.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpdateBudgetDto] updateBudgetDto (required):
  Future<Budget?> budgetControllerUpdateBudget(String id, UpdateBudgetDto updateBudgetDto, { Future<void>? abortTrigger, }) async {
    final response = await budgetControllerUpdateBudgetWithHttpInfo(id, updateBudgetDto, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Budget',) as Budget;

    }
    return null;
  }
}
