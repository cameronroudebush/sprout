//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class TransactionApi {
  TransactionApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Edit transaction.
  ///
  /// Edits a transaction by the given ID.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [Transaction] transaction (required):
  Future<Response> transactionControllerEditWithHttpInfo(String id, Transaction transaction,) async {
    // ignore: prefer_const_declarations
    final path = r'/transaction/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = transaction;

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

  /// Edit transaction.
  ///
  /// Edits a transaction by the given ID.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [Transaction] transaction (required):
  Future<Transaction?> transactionControllerEdit(String id, Transaction transaction,) async {
    final response = await transactionControllerEditWithHttpInfo(id, transaction,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Transaction',) as Transaction;
    
    }
    return null;
  }

  /// Get transactions by query.
  ///
  /// Retrieves transactions based on the provided query parameters.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [num] startIndex:
  ///   The starting index for pagination.
  ///
  /// * [num] endIndex:
  ///   The ending index for pagination.
  ///
  /// * [String] accountId:
  ///   The ID of the account to retrieve transactions from.
  ///
  /// * [String] category:
  ///   A specific category id you want data for. If you pass unknown here, we'll return all categories matching 'null'. If this is not populated, we'll simply return all categories.
  ///
  /// * [String] description:
  ///   A partial description to filter transactions.
  ///
  /// * [DateTime] date:
  ///   A specific date to filter transactions.
  Future<Response> transactionControllerGetByQueryWithHttpInfo({ num? startIndex, num? endIndex, String? accountId, String? category, String? description, DateTime? date, }) async {
    // ignore: prefer_const_declarations
    final path = r'/transaction';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (startIndex != null) {
      queryParams.addAll(_queryParams('', 'startIndex', startIndex));
    }
    if (endIndex != null) {
      queryParams.addAll(_queryParams('', 'endIndex', endIndex));
    }
    if (accountId != null) {
      queryParams.addAll(_queryParams('', 'accountId', accountId));
    }
    if (category != null) {
      queryParams.addAll(_queryParams('', 'category', category));
    }
    if (description != null) {
      queryParams.addAll(_queryParams('', 'description', description));
    }
    if (date != null) {
      queryParams.addAll(_queryParams('', 'date', date));
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

  /// Get transactions by query.
  ///
  /// Retrieves transactions based on the provided query parameters.
  ///
  /// Parameters:
  ///
  /// * [num] startIndex:
  ///   The starting index for pagination.
  ///
  /// * [num] endIndex:
  ///   The ending index for pagination.
  ///
  /// * [String] accountId:
  ///   The ID of the account to retrieve transactions from.
  ///
  /// * [String] category:
  ///   A specific category id you want data for. If you pass unknown here, we'll return all categories matching 'null'. If this is not populated, we'll simply return all categories.
  ///
  /// * [String] description:
  ///   A partial description to filter transactions.
  ///
  /// * [DateTime] date:
  ///   A specific date to filter transactions.
  Future<List<Transaction>?> transactionControllerGetByQuery({ num? startIndex, num? endIndex, String? accountId, String? category, String? description, DateTime? date, }) async {
    final response = await transactionControllerGetByQueryWithHttpInfo( startIndex: startIndex, endIndex: endIndex, accountId: accountId, category: category, description: description, date: date, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Transaction>') as List)
        .cast<Transaction>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get's the total count of transactions across accounts.
  ///
  /// Retrieves a count of the total number of transactions available for the current user including a total for each account.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> transactionControllerGetTotalWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/transaction/count';

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

  /// Get's the total count of transactions across accounts.
  ///
  /// Retrieves a count of the total number of transactions available for the current user including a total for each account.
  Future<TotalTransactions?> transactionControllerGetTotal() async {
    final response = await transactionControllerGetTotalWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TotalTransactions',) as TotalTransactions;
    
    }
    return null;
  }

  /// Get's subscriptions.
  ///
  /// Retrieves subscriptions based on historical transactions by guessing if they are reoccurring or not.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> transactionControllerSubscriptionsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/transaction/subscriptions';

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

  /// Get's subscriptions.
  ///
  /// Retrieves subscriptions based on historical transactions by guessing if they are reoccurring or not.
  Future<List<TransactionSubscription>?> transactionControllerSubscriptions() async {
    final response = await transactionControllerSubscriptionsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<TransactionSubscription>') as List)
        .cast<TransactionSubscription>()
        .toList(growable: false);

    }
    return null;
  }
}
