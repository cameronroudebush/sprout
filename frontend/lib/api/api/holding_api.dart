//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class HoldingApi {
  HoldingApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get holding history for a specific account.
  ///
  /// Retrieves holding history for the given account. This is useful for displaying the holdings value over time.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   The ID of the account to retrieve holding history for.
  Future<Response> holdingControllerGetHoldingHistoryWithHttpInfo(String accountId,) async {
    // ignore: prefer_const_declarations
    final path = r'/holding/history';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'accountId', accountId));

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

  /// Get holding history for a specific account.
  ///
  /// Retrieves holding history for the given account. This is useful for displaying the holdings value over time.
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   The ID of the account to retrieve holding history for.
  Future<List<EntityHistory>?> holdingControllerGetHoldingHistory(String accountId,) async {
    final response = await holdingControllerGetHoldingHistoryWithHttpInfo(accountId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<EntityHistory>') as List)
        .cast<EntityHistory>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get holdings for a specific account.
  ///
  /// Retrieves all holdings for the authenticated user within a specified account.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   The ID of the account to retrieve holdings for.
  Future<Response> holdingControllerGetHoldingsWithHttpInfo(String accountId,) async {
    // ignore: prefer_const_declarations
    final path = r'/holding';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'accountId', accountId));

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

  /// Get holdings for a specific account.
  ///
  /// Retrieves all holdings for the authenticated user within a specified account.
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   The ID of the account to retrieve holdings for.
  Future<List<Holding>?> holdingControllerGetHoldings(String accountId,) async {
    final response = await holdingControllerGetHoldingsWithHttpInfo(accountId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Holding>') as List)
        .cast<Holding>()
        .toList(growable: false);

    }
    return null;
  }
}
