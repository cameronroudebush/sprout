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
}
