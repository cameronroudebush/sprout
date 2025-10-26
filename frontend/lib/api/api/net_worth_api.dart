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

  /// Get net worth.
  ///
  /// Retrieves the current net worth for the authenticated user.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> netWorthControllerGetNetWorthWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/net-worth';

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

  /// Get net worth.
  ///
  /// Retrieves the current net worth for the authenticated user.
  Future<num?> netWorthControllerGetNetWorth() async {
    final response = await netWorthControllerGetNetWorthWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'num',) as num;
    
    }
    return null;
  }

  /// Get net worth by accounts.
  ///
  /// Retrieves the net worth overtime of each account associated to the current user. Useful for displaying in a chart.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> netWorthControllerGetNetWorthByAccountsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/net-worth/account';

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

  /// Get net worth by accounts.
  ///
  /// Retrieves the net worth overtime of each account associated to the current user. Useful for displaying in a chart.
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

  /// Get net worth.
  ///
  /// Retrieves the net worth overtime of the current user. Useful for displaying in a chart.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> netWorthControllerGetNetWorthOTWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/net-worth/ot';

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

  /// Get net worth.
  ///
  /// Retrieves the net worth overtime of the current user. Useful for displaying in a chart.
  Future<EntityHistory?> netWorthControllerGetNetWorthOT() async {
    final response = await netWorthControllerGetNetWorthOTWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'EntityHistory',) as EntityHistory;
    
    }
    return null;
  }
}
