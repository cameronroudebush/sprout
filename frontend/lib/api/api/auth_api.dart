//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AuthApi {
  AuthApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Login with username and password.
  ///
  /// Authenticates a user with their username and password, returning user details and a new JWT for requests. Only available on local strategy auth.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [UsernamePasswordLoginRequest] usernamePasswordLoginRequest (required):
  Future<Response> authControllerLoginWithHttpInfo(UsernamePasswordLoginRequest usernamePasswordLoginRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/login';

    // ignore: prefer_final_locals
    Object? postBody = usernamePasswordLoginRequest;

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

  /// Login with username and password.
  ///
  /// Authenticates a user with their username and password, returning user details and a new JWT for requests. Only available on local strategy auth.
  ///
  /// Parameters:
  ///
  /// * [UsernamePasswordLoginRequest] usernamePasswordLoginRequest (required):
  Future<UserLoginResponse?> authControllerLogin(UsernamePasswordLoginRequest usernamePasswordLoginRequest,) async {
    final response = await authControllerLoginWithHttpInfo(usernamePasswordLoginRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UserLoginResponse',) as UserLoginResponse;
    
    }
    return null;
  }

  /// Callback handler for the OIDC login.
  ///
  /// Handles the redirect back from the OIDC server and handles state control to get the authentication response back to the original requester.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] code (required):
  ///
  /// * [String] state (required):
  Future<Response> authControllerLoginCallbackOIDCWithHttpInfo(String code, String state,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/oidc/callback';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'code', code));
      queryParams.addAll(_queryParams('', 'state', state));

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

  /// Callback handler for the OIDC login.
  ///
  /// Handles the redirect back from the OIDC server and handles state control to get the authentication response back to the original requester.
  ///
  /// Parameters:
  ///
  /// * [String] code (required):
  ///
  /// * [String] state (required):
  Future<void> authControllerLoginCallbackOIDC(String code, String state,) async {
    final response = await authControllerLoginCallbackOIDCWithHttpInfo(code, state,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Authenticates using the OIDC configuration.
  ///
  /// Authenticates to our OIDC server that is configured and handles redirecting the authentication capability back to API to complete the login request.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] targetUrl (required):
  Future<Response> authControllerLoginOIDCWithHttpInfo(String targetUrl,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/oidc/login';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'target_url', targetUrl));

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

  /// Authenticates using the OIDC configuration.
  ///
  /// Authenticates to our OIDC server that is configured and handles redirecting the authentication capability back to API to complete the login request.
  ///
  /// Parameters:
  ///
  /// * [String] targetUrl (required):
  Future<void> authControllerLoginOIDC(String targetUrl,) async {
    final response = await authControllerLoginOIDCWithHttpInfo(targetUrl,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Login with an existing JWT.
  ///
  /// Validates an existing JWT. If valid, it returns the user details and the same JWT. Only available on local strategy auth.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [JWTLoginRequest] jWTLoginRequest (required):
  Future<Response> authControllerLoginWithJWTWithHttpInfo(JWTLoginRequest jWTLoginRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/login/jwt';

    // ignore: prefer_final_locals
    Object? postBody = jWTLoginRequest;

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

  /// Login with an existing JWT.
  ///
  /// Validates an existing JWT. If valid, it returns the user details and the same JWT. Only available on local strategy auth.
  ///
  /// Parameters:
  ///
  /// * [JWTLoginRequest] jWTLoginRequest (required):
  Future<UserLoginResponse?> authControllerLoginWithJWT(JWTLoginRequest jWTLoginRequest,) async {
    final response = await authControllerLoginWithJWTWithHttpInfo(jWTLoginRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UserLoginResponse',) as UserLoginResponse;
    
    }
    return null;
  }

  /// Logout the user
  ///
  /// Clears the session cookies any authentication that has happened.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> authControllerLogoutWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/auth/logout';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Logout the user
  ///
  /// Clears the session cookies any authentication that has happened.
  Future<void> authControllerLogout() async {
    final response = await authControllerLogoutWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Proxy OIDC refresh requests.
  ///
  /// Proxies OIDC token refresh to the destination server of the OIDC issuer.  Only available on OIDC strategy auth.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RefreshRequestDTO] refreshRequestDTO (required):
  Future<Response> authControllerRefreshWithHttpInfo(RefreshRequestDTO refreshRequestDTO,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/oidc/refresh';

    // ignore: prefer_final_locals
    Object? postBody = refreshRequestDTO;

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

  /// Proxy OIDC refresh requests.
  ///
  /// Proxies OIDC token refresh to the destination server of the OIDC issuer.  Only available on OIDC strategy auth.
  ///
  /// Parameters:
  ///
  /// * [RefreshRequestDTO] refreshRequestDTO (required):
  Future<RefreshResponseDTO?> authControllerRefresh(RefreshRequestDTO refreshRequestDTO,) async {
    final response = await authControllerRefreshWithHttpInfo(refreshRequestDTO,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RefreshResponseDTO',) as RefreshResponseDTO;
    
    }
    return null;
  }
}
