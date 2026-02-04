//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ChatApi {
  ChatApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Returns the chat history for previous LLM conversations.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> chatControllerHistoryWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/chat/history';

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

  /// Returns the chat history for previous LLM conversations.
  Future<List<ChatHistory>?> chatControllerHistory() async {
    final response = await chatControllerHistoryWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<ChatHistory>') as List)
        .cast<ChatHistory>()
        .toList(growable: false);

    }
    return null;
  }

  /// Utilizes the LLM prompt engine to help you discuss your finances.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ChatRequestDTO] chatRequestDTO (required):
  Future<Response> chatControllerNewWithHttpInfo(ChatRequestDTO chatRequestDTO,) async {
    // ignore: prefer_const_declarations
    final path = r'/chat/new';

    // ignore: prefer_final_locals
    Object? postBody = chatRequestDTO;

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

  /// Utilizes the LLM prompt engine to help you discuss your finances.
  ///
  /// Parameters:
  ///
  /// * [ChatRequestDTO] chatRequestDTO (required):
  Future<void> chatControllerNew(ChatRequestDTO chatRequestDTO,) async {
    final response = await chatControllerNewWithHttpInfo(chatRequestDTO,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
