//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class UserConfigApi {
  UserConfigApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Edit user config.
  ///
  /// Edits the current users configuration.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [UserConfig] userConfig (required):
  Future<Response> userConfigControllerEditWithHttpInfo(UserConfig userConfig,) async {
    // ignore: prefer_const_declarations
    final path = r'/user-config';

    // ignore: prefer_final_locals
    Object? postBody = userConfig;

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

  /// Edit user config.
  ///
  /// Edits the current users configuration.
  ///
  /// Parameters:
  ///
  /// * [UserConfig] userConfig (required):
  Future<UserConfig?> userConfigControllerEdit(UserConfig userConfig,) async {
    final response = await userConfigControllerEditWithHttpInfo(userConfig,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UserConfig',) as UserConfig;
    
    }
    return null;
  }

  /// Get user config.
  ///
  /// Retrieves the current user's configuration.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> userConfigControllerGetWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/user-config';

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

  /// Get user config.
  ///
  /// Retrieves the current user's configuration.
  Future<UserConfig?> userConfigControllerGet() async {
    final response = await userConfigControllerGetWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UserConfig',) as UserConfig;
    
    }
    return null;
  }
}
