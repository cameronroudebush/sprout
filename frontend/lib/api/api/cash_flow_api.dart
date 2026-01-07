//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class CashFlowApi {
  CashFlowApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get sankey data by query.
  ///
  /// Retrieves a model that can be used to render a sankey diagram based on the current authenticated users cash flow.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [num] year (required):
  ///   The year we want the cash flow data for.
  ///
  /// * [num] month:
  ///   The month we want the cash flow data for. If not given, assumes we want the whole year.
  ///
  /// * [num] day:
  ///   The day we want the cash flow data for. If not given, assumes to include the entire month. If the month is not included in your query, this is ignored.
  ///
  /// * [String] accountId:
  ///   The ID of the account to retrieve transactions from.
  Future<Response> cashFlowControllerGetSankeyWithHttpInfo(num year, { num? month, num? day, String? accountId, }) async {
    // ignore: prefer_const_declarations
    final path = r'/cash-flow/sankey';

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

  /// Get sankey data by query.
  ///
  /// Retrieves a model that can be used to render a sankey diagram based on the current authenticated users cash flow.
  ///
  /// Parameters:
  ///
  /// * [num] year (required):
  ///   The year we want the cash flow data for.
  ///
  /// * [num] month:
  ///   The month we want the cash flow data for. If not given, assumes we want the whole year.
  ///
  /// * [num] day:
  ///   The day we want the cash flow data for. If not given, assumes to include the entire month. If the month is not included in your query, this is ignored.
  ///
  /// * [String] accountId:
  ///   The ID of the account to retrieve transactions from.
  Future<SankeyData?> cashFlowControllerGetSankey(num year, { num? month, num? day, String? accountId, }) async {
    final response = await cashFlowControllerGetSankeyWithHttpInfo(year,  month: month, day: day, accountId: accountId, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SankeyData',) as SankeyData;
    
    }
    return null;
  }

  /// Get cash flow spending stats per month.
  ///
  /// Returns monthly spending breakdown for the requested look-back period, isolating top N categories.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [num] months (required):
  ///
  /// * [num] categories (required):
  Future<Response> cashFlowControllerGetSpendingWithHttpInfo(num months, num categories,) async {
    // ignore: prefer_const_declarations
    final path = r'/cash-flow/spending';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'months', months));
      queryParams.addAll(_queryParams('', 'categories', categories));

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

  /// Get cash flow spending stats per month.
  ///
  /// Returns monthly spending breakdown for the requested look-back period, isolating top N categories.
  ///
  /// Parameters:
  ///
  /// * [num] months (required):
  ///
  /// * [num] categories (required):
  Future<CashFlowSpending?> cashFlowControllerGetSpending(num months, num categories,) async {
    final response = await cashFlowControllerGetSpendingWithHttpInfo(months, categories,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CashFlowSpending',) as CashFlowSpending;
    
    }
    return null;
  }

  /// Get cash flow stats data by query.
  ///
  /// Retrieves stats for the users cash flow in more basic terms. Tracking how much went out and how much came in.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [num] year (required):
  ///   The year we want the cash flow data for.
  ///
  /// * [num] month:
  ///   The month we want the cash flow data for. If not given, assumes we want the whole year.
  ///
  /// * [num] day:
  ///   The day we want the cash flow data for. If not given, assumes to include the entire month. If the month is not included in your query, this is ignored.
  ///
  /// * [String] accountId:
  ///   The ID of the account to retrieve transactions from.
  Future<Response> cashFlowControllerGetStatsWithHttpInfo(num year, { num? month, num? day, String? accountId, }) async {
    // ignore: prefer_const_declarations
    final path = r'/cash-flow/stats';

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

  /// Get cash flow stats data by query.
  ///
  /// Retrieves stats for the users cash flow in more basic terms. Tracking how much went out and how much came in.
  ///
  /// Parameters:
  ///
  /// * [num] year (required):
  ///   The year we want the cash flow data for.
  ///
  /// * [num] month:
  ///   The month we want the cash flow data for. If not given, assumes we want the whole year.
  ///
  /// * [num] day:
  ///   The day we want the cash flow data for. If not given, assumes to include the entire month. If the month is not included in your query, this is ignored.
  ///
  /// * [String] accountId:
  ///   The ID of the account to retrieve transactions from.
  Future<CashFlowStats?> cashFlowControllerGetStats(num year, { num? month, num? day, String? accountId, }) async {
    final response = await cashFlowControllerGetStatsWithHttpInfo(year,  month: month, day: day, accountId: accountId, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CashFlowStats',) as CashFlowStats;
    
    }
    return null;
  }
}
