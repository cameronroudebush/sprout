//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class UserApi {
  UserApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create a new user.
  ///
  /// Allows for the creation of a new user. Only works during initial setup of the app.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [UserCreationRequest] userCreationRequest (required):
  Future<Response> userControllerCreateWithHttpInfo(UserCreationRequest userCreationRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/user/create';

    // ignore: prefer_final_locals
    Object? postBody = userCreationRequest;

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

  /// Create a new user.
  ///
  /// Allows for the creation of a new user. Only works during initial setup of the app.
  ///
  /// Parameters:
  ///
  /// * [UserCreationRequest] userCreationRequest (required):
  Future<UserCreationResponse?> userControllerCreate(UserCreationRequest userCreationRequest,) async {
    final response = await userControllerCreateWithHttpInfo(userCreationRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UserCreationResponse',) as UserCreationResponse;
    
    }
    return null;
  }

  /// Get user by ID.
  ///
  /// Retrieves a user's information by their ID.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> userControllerGetByIdWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/user/{id}'
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

  /// Get user by ID.
  ///
  /// Retrieves a user's information by their ID.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<User?> userControllerGetById(String id,) async {
    final response = await userControllerGetByIdWithHttpInfo(id,);
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

  /// Login with username and password.
  ///
  /// Authenticates a user with their username and password, returning user details and a new JWT for session management.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [UsernamePasswordLoginRequest] usernamePasswordLoginRequest (required):
  Future<Response> userControllerLoginWithHttpInfo(UsernamePasswordLoginRequest usernamePasswordLoginRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/user/login';

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
  /// Authenticates a user with their username and password, returning user details and a new JWT for session management.
  ///
  /// Parameters:
  ///
  /// * [UsernamePasswordLoginRequest] usernamePasswordLoginRequest (required):
  Future<UserLoginResponse?> userControllerLogin(UsernamePasswordLoginRequest usernamePasswordLoginRequest,) async {
    final response = await userControllerLoginWithHttpInfo(usernamePasswordLoginRequest,);
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
  /// Validates an existing JWT. If valid, it returns the user details and the same JWT.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [JWTLoginRequest] jWTLoginRequest (required):
  Future<Response> userControllerLoginWithJWTWithHttpInfo(JWTLoginRequest jWTLoginRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/user/login/jwt';

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
  /// Validates an existing JWT. If valid, it returns the user details and the same JWT.
  ///
  /// Parameters:
  ///
  /// * [JWTLoginRequest] jWTLoginRequest (required):
  Future<UserLoginResponse?> userControllerLoginWithJWT(JWTLoginRequest jWTLoginRequest,) async {
    final response = await userControllerLoginWithJWTWithHttpInfo(jWTLoginRequest,);
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
