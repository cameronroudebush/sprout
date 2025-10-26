//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class CoreApi {
  CoreApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Check application status.
  ///
  /// Provides a return message if the app is running.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> coreControllerHeartbeatWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/core/heartbeat';

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

  /// Check application status.
  ///
  /// Provides a return message if the app is running.
  Future<String?> coreControllerHeartbeat() async {
    final response = await coreControllerHeartbeatWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'String',) as String;
    
    }
    return null;
  }

  /// Proxy images for institutions.
  ///
  /// Proxies images from external URLs, handling CORS issues and dynamically fetching images. Supports full image URLs or favicon lookups.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [Object] faviconImageUrl:
  ///   A base URL to fetch a favicon for. Used if fullImageUrl is not provided.
  ///
  /// * [Object] fullImageUrl:
  ///   A full URL to an image. If provided, faviconImageUrl will be ignored.
  Future<Response> imageProxyControllerHandleImageProxyWithHttpInfo({ Object? faviconImageUrl, Object? fullImageUrl, }) async {
    // ignore: prefer_const_declarations
    final path = r'/image-proxy';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (faviconImageUrl != null) {
      queryParams.addAll(_queryParams('', 'faviconImageUrl', faviconImageUrl));
    }
    if (fullImageUrl != null) {
      queryParams.addAll(_queryParams('', 'fullImageUrl', fullImageUrl));
    }

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

  /// Proxy images for institutions.
  ///
  /// Proxies images from external URLs, handling CORS issues and dynamically fetching images. Supports full image URLs or favicon lookups.
  ///
  /// Parameters:
  ///
  /// * [Object] faviconImageUrl:
  ///   A base URL to fetch a favicon for. Used if fullImageUrl is not provided.
  ///
  /// * [Object] fullImageUrl:
  ///   A full URL to an image. If provided, faviconImageUrl will be ignored.
  Future<void> imageProxyControllerHandleImageProxy({ Object? faviconImageUrl, Object? fullImageUrl, }) async {
    final response = await imageProxyControllerHandleImageProxyWithHttpInfo( faviconImageUrl: faviconImageUrl, fullImageUrl: fullImageUrl, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Subscribe to real-time server events to allow the server to inform our client of various info.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> sSEControllerSseWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/sse';

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

  /// Subscribe to real-time server events to allow the server to inform our client of various info.
  Future<SSEData?> sSEControllerSse() async {
    final response = await sSEControllerSseWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SSEData',) as SSEData;
    
    }
    return null;
  }
}
