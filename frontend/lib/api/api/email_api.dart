//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class EmailApi {
  EmailApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Send Test Weekly Email
  ///
  /// Notifies the current user about their weekly update via email. Only works in dev mode.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> emailControllerNotifyWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/email/test/email/weekly';

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

  /// Send Test Weekly Email
  ///
  /// Notifies the current user about their weekly update via email. Only works in dev mode.
  Future<void> emailControllerNotify() async {
    final response = await emailControllerNotifyWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Preview Weekly Update Email
  ///
  /// Renders the weekly update email with some fake data. Only works in dev mode.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> emailControllerPreviewWeeklyUpdateWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/email/preview/weekly-update';

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

  /// Preview Weekly Update Email
  ///
  /// Renders the weekly update email with some fake data. Only works in dev mode.
  Future<void> emailControllerPreviewWeeklyUpdate() async {
    final response = await emailControllerPreviewWeeklyUpdateWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
