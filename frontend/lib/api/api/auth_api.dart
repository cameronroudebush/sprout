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
  Future<User?> authControllerLogin(UsernamePasswordLoginRequest usernamePasswordLoginRequest,) async {
    final response = await authControllerLoginWithHttpInfo(usernamePasswordLoginRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'User',) as User;
    
    }
    return null;
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
  Future<User?> authControllerLoginWithJWT(JWTLoginRequest jWTLoginRequest,) async {
    final response = await authControllerLoginWithJWTWithHttpInfo(jWTLoginRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'User',) as User;
    
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

  /// Exchange session code for cookies
  ///
  /// This seeds the mobile CookieJar and is only intended to be used with mobile apps. We implement our own PKCE implementation to protect against interception attacks.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [MobileTokenExchangeDto] mobileTokenExchangeDto (required):
  Future<Response> oIDCControllerExchangeWithHttpInfo(MobileTokenExchangeDto mobileTokenExchangeDto,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/oidc/exchange';

    // ignore: prefer_final_locals
    Object? postBody = mobileTokenExchangeDto;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


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

  /// Exchange session code for cookies
  ///
  /// This seeds the mobile CookieJar and is only intended to be used with mobile apps. We implement our own PKCE implementation to protect against interception attacks.
  ///
  /// Parameters:
  ///
  /// * [MobileTokenExchangeDto] mobileTokenExchangeDto (required):
  Future<void> oIDCControllerExchange(MobileTokenExchangeDto mobileTokenExchangeDto,) async {
    final response = await oIDCControllerExchangeWithHttpInfo(mobileTokenExchangeDto,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
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
  Future<Response> oIDCControllerLoginCallbackOIDCWithHttpInfo(String code, String state,) async {
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
  Future<void> oIDCControllerLoginCallbackOIDC(String code, String state,) async {
    final response = await oIDCControllerLoginCallbackOIDCWithHttpInfo(code, state,);
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
  ///
  /// * [String] appChallenge (required):
  Future<Response> oIDCControllerLoginOIDCWithHttpInfo(String targetUrl, String appChallenge,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/oidc/login';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'target_url', targetUrl));
      queryParams.addAll(_queryParams('', 'app_challenge', appChallenge));

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
  ///
  /// * [String] appChallenge (required):
  Future<void> oIDCControllerLoginOIDC(String targetUrl, String appChallenge,) async {
    final response = await oIDCControllerLoginOIDCWithHttpInfo(targetUrl, appChallenge,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
