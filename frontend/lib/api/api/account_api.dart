//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AccountApi {
  AccountApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Delete account by ID.
  ///
  /// Deletes an account by the given ID.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> accountControllerDeleteWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/account/{id}'
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

  /// Delete account by ID.
  ///
  /// Deletes an account by the given ID.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<void> accountControllerDelete(String id,) async {
    final response = await accountControllerDeleteWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Edit account.
  ///
  /// Edits an account by the given ID.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [AccountEditRequest] accountEditRequest (required):
  Future<Response> accountControllerEditWithHttpInfo(String id, AccountEditRequest accountEditRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/account/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = accountEditRequest;

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

  /// Edit account.
  ///
  /// Edits an account by the given ID.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [AccountEditRequest] accountEditRequest (required):
  Future<Account?> accountControllerEdit(String id, AccountEditRequest accountEditRequest,) async {
    final response = await accountControllerEditWithHttpInfo(id, accountEditRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Account',) as Account;
    
    }
    return null;
  }

  /// Get accounts.
  ///
  /// Retrieves all accounts for the authenticated user.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> accountControllerGetAccountsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/account';

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

  /// Get accounts.
  ///
  /// Retrieves all accounts for the authenticated user.
  Future<List<Account>?> accountControllerGetAccounts() async {
    final response = await accountControllerGetAccountsWithHttpInfo();
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

  /// Get account by ID.
  ///
  /// Retrieves an account by the given ID.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> accountControllerGetByIdWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/account/{id}'
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

  /// Get account by ID.
  ///
  /// Retrieves an account by the given ID.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Account?> accountControllerGetById(String id,) async {
    final response = await accountControllerGetByIdWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Account',) as Account;
    
    }
    return null;
  }

  /// Get accounts from a provider that are not yet synced.
  ///
  /// Retrieves accounts from a specified provider that the user has not yet linked.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] name (required):
  Future<Response> accountControllerGetProviderAccountsWithHttpInfo(String name,) async {
    // ignore: prefer_const_declarations
    final path = r'/account/provider/{name}'
      .replaceAll('{name}', name);

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

  /// Get accounts from a provider that are not yet synced.
  ///
  /// Retrieves accounts from a specified provider that the user has not yet linked.
  ///
  /// Parameters:
  ///
  /// * [String] name (required):
  Future<List<Account>?> accountControllerGetProviderAccounts(String name,) async {
    final response = await accountControllerGetProviderAccountsWithHttpInfo(name,);
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

  /// Link the new given accounts from a provider.
  ///
  /// Given some accounts and the provider info, links new accounts to the current user.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] name (required):
  ///
  /// * [List<Account>] account (required):
  Future<Response> accountControllerLinkProviderAccountsWithHttpInfo(String name, List<Account> account,) async {
    // ignore: prefer_const_declarations
    final path = r'/account/provider/{name}/link'
      .replaceAll('{name}', name);

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

  /// Link the new given accounts from a provider.
  ///
  /// Given some accounts and the provider info, links new accounts to the current user.
  ///
  /// Parameters:
  ///
  /// * [String] name (required):
  ///
  /// * [List<Account>] account (required):
  Future<List<Account>?> accountControllerLinkProviderAccounts(String name, List<Account> account,) async {
    final response = await accountControllerLinkProviderAccountsWithHttpInfo(name, account,);
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

  /// Run a manual sync.
  ///
  /// Runs a manual sync to update all provider accounts.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> accountControllerManualSyncWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/account/sync';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Run a manual sync.
  ///
  /// Runs a manual sync to update all provider accounts.
  Future<void> accountControllerManualSync() async {
    final response = await accountControllerManualSyncWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
