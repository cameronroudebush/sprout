//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ConfigApi {
  ConfigApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get app configuration.
  ///
  /// Returns the app configuration for the frontend to be able to reference.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> configControllerGetWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/config';

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

  /// Get app configuration.
  ///
  /// Returns the app configuration for the frontend to be able to reference.
  Future<APIConfig?> configControllerGet() async {
    final response = await configControllerGetWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'APIConfig',) as APIConfig;
    
    }
    return null;
  }

  /// Get unsecure app configuration.
  ///
  /// Returns the unsecure app configuration. This won't contain any sensitive information but tells endpoints if the first time setup needs ran.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> configControllerGetUnsecureWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/config/unsecure';

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

  /// Get unsecure app configuration.
  ///
  /// Returns the unsecure app configuration. This won't contain any sensitive information but tells endpoints if the first time setup needs ran.
  Future<UnsecureAppConfiguration?> configControllerGetUnsecure() async {
    final response = await configControllerGetUnsecureWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UnsecureAppConfiguration',) as UnsecureAppConfiguration;
    
    }
    return null;
  }
}
