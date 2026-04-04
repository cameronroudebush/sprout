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

  /// Get provider configuration.
  ///
  /// Returns the provider configuration so we know what providers are available.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> baseProviderControllerGetConfigWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/provider/config';

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

  /// Get provider configuration.
  ///
  /// Returns the provider configuration so we know what providers are available.
  Future<List<ProviderConfig>?> baseProviderControllerGetConfig() async {
    final response = await baseProviderControllerGetConfigWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<ProviderConfig>') as List)
        .cast<ProviderConfig>()
        .toList(growable: false);

    }
    return null;
  }

  /// Create a Plaid link token
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] institutionId:
  Future<Response> plaidProviderControllerCreateLinkTokenWithHttpInfo({ String? institutionId, }) async {
    // ignore: prefer_const_declarations
    final path = r'/provider/plaid/create-link-token';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (institutionId != null) {
      queryParams.addAll(_queryParams('', 'institutionId', institutionId));
    }

    const contentTypes = <String>[];


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

  /// Create a Plaid link token
  ///
  /// Parameters:
  ///
  /// * [String] institutionId:
  Future<PlaidLinkTokenDTO?> plaidProviderControllerCreateLinkToken({ String? institutionId, }) async {
    final response = await plaidProviderControllerCreateLinkTokenWithHttpInfo( institutionId: institutionId, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PlaidLinkTokenDTO',) as PlaidLinkTokenDTO;
    
    }
    return null;
  }

  /// Exchange Public Token
  ///
  /// Finalizes the link by exchanging the public token and saving accounts to the DB.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [PlaidLinkDTO] plaidLinkDTO (required):
  Future<Response> plaidProviderControllerExchangeAndLinkWithHttpInfo(PlaidLinkDTO plaidLinkDTO,) async {
    // ignore: prefer_const_declarations
    final path = r'/provider/plaid/exchange-token';

    // ignore: prefer_final_locals
    Object? postBody = plaidLinkDTO;

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

  /// Exchange Public Token
  ///
  /// Finalizes the link by exchanging the public token and saving accounts to the DB.
  ///
  /// Parameters:
  ///
  /// * [PlaidLinkDTO] plaidLinkDTO (required):
  Future<List<Account>?> plaidProviderControllerExchangeAndLink(PlaidLinkDTO plaidLinkDTO,) async {
    final response = await plaidProviderControllerExchangeAndLinkWithHttpInfo(plaidLinkDTO,);
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

  /// Get property info from Zillow
  ///
  /// Grabs zillow asset data based on the account given.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   The ID of the account to lookup
  Future<Response> zillowProviderControllerGetByAccountWithHttpInfo(String accountId,) async {
    // ignore: prefer_const_declarations
    final path = r'/provider/zillow/{accountId}'
      .replaceAll('{accountId}', accountId);

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

  /// Get property info from Zillow
  ///
  /// Grabs zillow asset data based on the account given.
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   The ID of the account to lookup
  Future<ZillowAsset?> zillowProviderControllerGetByAccount(String accountId,) async {
    final response = await zillowProviderControllerGetByAccountWithHttpInfo(accountId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ZillowAsset',) as ZillowAsset;
    
    }
    return null;
  }

  /// Link a Zillow property as an account.
  ///
  /// Verifies property info and creates a tracked account with Zestimate value.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ZillowPropertyDTO] zillowPropertyDTO (required):
  Future<Response> zillowProviderControllerLinkWithHttpInfo(ZillowPropertyDTO zillowPropertyDTO,) async {
    // ignore: prefer_const_declarations
    final path = r'/provider/zillow/link';

    // ignore: prefer_final_locals
    Object? postBody = zillowPropertyDTO;

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

  /// Link a Zillow property as an account.
  ///
  /// Verifies property info and creates a tracked account with Zestimate value.
  ///
  /// Parameters:
  ///
  /// * [ZillowPropertyDTO] zillowPropertyDTO (required):
  Future<Account?> zillowProviderControllerLink(ZillowPropertyDTO zillowPropertyDTO,) async {
    final response = await zillowProviderControllerLinkWithHttpInfo(zillowPropertyDTO,);
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

  /// Get property info from Zillow
  ///
  /// Grabs data from zillow for Zpid, Zestimate, and Rent Zestimate based on address.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ZillowPropertyDTO] zillowPropertyDTO (required):
  Future<Response> zillowProviderControllerLookupPropertyWithHttpInfo(ZillowPropertyDTO zillowPropertyDTO,) async {
    // ignore: prefer_const_declarations
    final path = r'/provider/zillow/lookup';

    // ignore: prefer_final_locals
    Object? postBody = zillowPropertyDTO;

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

  /// Get property info from Zillow
  ///
  /// Grabs data from zillow for Zpid, Zestimate, and Rent Zestimate based on address.
  ///
  /// Parameters:
  ///
  /// * [ZillowPropertyDTO] zillowPropertyDTO (required):
  Future<ZillowPropertyResultDto?> zillowProviderControllerLookupProperty(ZillowPropertyDTO zillowPropertyDTO,) async {
    final response = await zillowProviderControllerLookupPropertyWithHttpInfo(zillowPropertyDTO,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ZillowPropertyResultDto',) as ZillowPropertyResultDto;
    
    }
    return null;
  }
}
