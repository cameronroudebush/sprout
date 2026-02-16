//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class NetWorthApi {
  NetWorthApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get net worth by ALL accounts represented as time frames.
  ///
  /// Retrieves the net worth overtime of each account associated to the current user. Does not include any timeline data.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> netWorthControllerGetNetWorthByAccountsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/net-worth/accounts';

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

  /// Get net worth by ALL accounts represented as time frames.
  ///
  /// Retrieves the net worth overtime of each account associated to the current user. Does not include any timeline data.
  Future<List<EntityHistory>?> netWorthControllerGetNetWorthByAccounts() async {
    final response = await netWorthControllerGetNetWorthByAccountsWithHttpInfo();
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

  /// Get net worth over time (timeline) of a specific account.
  ///
  /// Retrieves the net worth overtime for the specific given account
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> netWorthControllerGetNetWorthTimelineAccountWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/net-worth/timeline/account/{id}'
      .replaceAll('{id}', id);

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

  /// Get net worth over time (timeline) of a specific account.
  ///
  /// Retrieves the net worth overtime for the specific given account
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<List<HistoricalDataPoint>?> netWorthControllerGetNetWorthTimelineAccount(String id,) async {
    final response = await netWorthControllerGetNetWorthTimelineAccountWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<HistoricalDataPoint>') as List)
        .cast<HistoricalDataPoint>()
        .toList(growable: false);

    }
    return null;
  }

  /// Retrieves the historical net-worth data for all accounts.
  ///
  /// Retrieves all data related to the overarching accounts and how they performed over time.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> netWorthControllerGetNetWorthTotalWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/net-worth/total';

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

  /// Retrieves the historical net-worth data for all accounts.
  ///
  /// Retrieves all data related to the overarching accounts and how they performed over time.
  Future<TotalNetWorthDTO?> netWorthControllerGetNetWorthTotal() async {
    final response = await netWorthControllerGetNetWorthTotalWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TotalNetWorthDTO',) as TotalNetWorthDTO;
    
    }
    return null;
  }
}
