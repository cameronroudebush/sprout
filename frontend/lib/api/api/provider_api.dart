//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ProviderApi {
  ProviderApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get accounts from the simple-fin provider that are not yet synced.
  ///
  /// Retrieves accounts that the user has not yet linked.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> simpleFinProviderControllerGetAccountsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/provider/simple-fin';

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

  /// Get accounts from the simple-fin provider that are not yet synced.
  ///
  /// Retrieves accounts that the user has not yet linked.
  Future<List<Account>?> simpleFinProviderControllerGetAccounts() async {
    final response = await simpleFinProviderControllerGetAccountsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Account>') as List)
        .cast<Account>()
        .toList(growable: false);

    }
    return null;
  }

  /// Link the new given accounts from simple-fin.
  ///
  /// Given some accounts, links the new accounts to the current user.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [List<Account>] account (required):
  Future<Response> simpleFinProviderControllerLinkAccountsWithHttpInfo(List<Account> account,) async {
    // ignore: prefer_const_declarations
    final path = r'/provider/simple-fin/link';

    // ignore: prefer_final_locals
    Object? postBody = account;

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

  /// Link the new given accounts from simple-fin.
  ///
  /// Given some accounts, links the new accounts to the current user.
  ///
  /// Parameters:
  ///
  /// * [List<Account>] account (required):
  Future<List<Account>?> simpleFinProviderControllerLinkAccounts(List<Account> account,) async {
    final response = await simpleFinProviderControllerLinkAccountsWithHttpInfo(account,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Account>') as List)
        .cast<Account>()
        .toList(growable: false);

    }
    return null;
  }
}
