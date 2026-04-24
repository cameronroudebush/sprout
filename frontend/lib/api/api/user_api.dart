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
  /// Allows for user creation based on either first time setup configuration or OIDC user config.
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
  /// Allows for user creation based on either first time setup configuration or OIDC user config.
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
  /// Retrieves a user's information by their Id. Only provides relevant information.
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
  /// Retrieves a user's information by their Id. Only provides relevant information.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<UserGetDTO?> userControllerGetById(String id,) async {
    final response = await userControllerGetByIdWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UserGetDTO',) as UserGetDTO;
    
    }
    return null;
  }

  /// Get's current user info.
  ///
  /// Returns the current user from the database.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> userControllerMeWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/user/me';

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

  /// Get's current user info.
  ///
  /// Returns the current user from the database.
  Future<User?> userControllerMe() async {
    final response = await userControllerMeWithHttpInfo();
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

  /// Register a device to a user.
  ///
  /// Registers a device to the current authenticated user so we can reference it in notification handlers.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RegisterDeviceDto] registerDeviceDto (required):
  Future<Response> userControllerRegisterDeviceWithHttpInfo(RegisterDeviceDto registerDeviceDto,) async {
    // ignore: prefer_const_declarations
    final path = r'/user/device/register';

    // ignore: prefer_final_locals
    Object? postBody = registerDeviceDto;

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

  /// Register a device to a user.
  ///
  /// Registers a device to the current authenticated user so we can reference it in notification handlers.
  ///
  /// Parameters:
  ///
  /// * [RegisterDeviceDto] registerDeviceDto (required):
  Future<void> userControllerRegisterDevice(RegisterDeviceDto registerDeviceDto,) async {
    final response = await userControllerRegisterDeviceWithHttpInfo(registerDeviceDto,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Update current user profile.
  ///
  /// Allows the authenticated user to update their email and other profile details.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [UpdateUserDto] updateUserDto (required):
  Future<Response> userControllerUpdateMeWithHttpInfo(UpdateUserDto updateUserDto,) async {
    // ignore: prefer_const_declarations
    final path = r'/user/me';

    // ignore: prefer_final_locals
    Object? postBody = updateUserDto;

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

  /// Update current user profile.
  ///
  /// Allows the authenticated user to update their email and other profile details.
  ///
  /// Parameters:
  ///
  /// * [UpdateUserDto] updateUserDto (required):
  Future<User?> userControllerUpdateMe(UpdateUserDto updateUserDto,) async {
    final response = await userControllerUpdateMeWithHttpInfo(updateUserDto,);
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
}
