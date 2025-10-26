//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class TransactionRuleApi {
  TransactionRuleApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Creates a new transaction rule.
  ///
  /// Creates a new transaction rule based on the given content and runs a processor so we can organize our current transactions.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [TransactionRule] transactionRule (required):
  Future<Response> transactionRuleControllerCreateWithHttpInfo(TransactionRule transactionRule,) async {
    // ignore: prefer_const_declarations
    final path = r'/transaction-rule';

    // ignore: prefer_final_locals
    Object? postBody = transactionRule;

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

  /// Creates a new transaction rule.
  ///
  /// Creates a new transaction rule based on the given content and runs a processor so we can organize our current transactions.
  ///
  /// Parameters:
  ///
  /// * [TransactionRule] transactionRule (required):
  Future<TransactionRule?> transactionRuleControllerCreate(TransactionRule transactionRule,) async {
    final response = await transactionRuleControllerCreateWithHttpInfo(transactionRule,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TransactionRule',) as TransactionRule;
    
    }
    return null;
  }

  /// Delete transaction rule by ID.
  ///
  /// Deletes a transaction rule by the given ID then runs a transaction update to re-categorize transactions.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> transactionRuleControllerDeleteWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/transaction-rule/{id}'
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

  /// Delete transaction rule by ID.
  ///
  /// Deletes a transaction rule by the given ID then runs a transaction update to re-categorize transactions.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<void> transactionRuleControllerDelete(String id,) async {
    final response = await transactionRuleControllerDeleteWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Edit transaction rule.
  ///
  /// Edits a transaction rule by the given ID.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [TransactionRule] transactionRule (required):
  Future<Response> transactionRuleControllerEditWithHttpInfo(String id, TransactionRule transactionRule,) async {
    // ignore: prefer_const_declarations
    final path = r'/transaction-rule/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = transactionRule;

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

  /// Edit transaction rule.
  ///
  /// Edits a transaction rule by the given ID.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [TransactionRule] transactionRule (required):
  Future<TransactionRule?> transactionRuleControllerEdit(String id, TransactionRule transactionRule,) async {
    final response = await transactionRuleControllerEditWithHttpInfo(id, transactionRule,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TransactionRule',) as TransactionRule;
    
    }
    return null;
  }

  /// Get transaction rules.
  ///
  /// Retrieves all transaction rules for the authenticated user.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> transactionRuleControllerGetWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/transaction-rule';

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

  /// Get transaction rules.
  ///
  /// Retrieves all transaction rules for the authenticated user.
  Future<List<TransactionRule>?> transactionRuleControllerGet() async {
    final response = await transactionRuleControllerGetWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<TransactionRule>') as List)
        .cast<TransactionRule>()
        .toList(growable: false);

    }
    return null;
  }
}
