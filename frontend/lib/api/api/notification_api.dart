//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class NotificationApi {
  NotificationApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get's a notification by it's id.
  ///
  /// Returns a specific notification for the specific user by it's ID.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> notificationControllerGetByIdWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/notification/{id}'
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

  /// Get's a notification by it's id.
  ///
  /// Returns a specific notification for the specific user by it's ID.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Notification?> notificationControllerGetById(String id,) async {
    final response = await notificationControllerGetByIdWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Notification',) as Notification;
    
    }
    return null;
  }

  /// Returns the firebase configuration.
  ///
  /// Since this is a self hosted app, if you want notifications you must configure them manually. This endpoint provides the config to the frontend's.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> notificationControllerGetFirebaseConfigWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/notification/config/firebase';

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

  /// Returns the firebase configuration.
  ///
  /// Since this is a self hosted app, if you want notifications you must configure them manually. This endpoint provides the config to the frontend's.
  Future<FirebaseConfigDTO?> notificationControllerGetFirebaseConfig() async {
    final response = await notificationControllerGetFirebaseConfigWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'FirebaseConfigDTO',) as FirebaseConfigDTO;
    
    }
    return null;
  }

  /// Get's the notifications
  ///
  /// Returns all the notifications for the currently authenticated user.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> notificationControllerGetNotificationsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/notification';

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

  /// Get's the notifications
  ///
  /// Returns all the notifications for the currently authenticated user.
  Future<List<Notification>?> notificationControllerGetNotifications() async {
    final response = await notificationControllerGetNotificationsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Notification>') as List)
        .cast<Notification>()
        .toList(growable: false);

    }
    return null;
  }
}
