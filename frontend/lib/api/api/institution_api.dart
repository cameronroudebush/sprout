//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class InstitutionApi {
  InstitutionApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Update institution.
  ///
  /// Updates properties supported by the DTO for the specific institution.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpdateInstitutionRequest] updateInstitutionRequest (required):
  Future<Response> institutionControllerUpdateWithHttpInfo(String id, UpdateInstitutionRequest updateInstitutionRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/institution/{id}/update'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = updateInstitutionRequest;

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

  /// Update institution.
  ///
  /// Updates properties supported by the DTO for the specific institution.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpdateInstitutionRequest] updateInstitutionRequest (required):
  Future<Institution?> institutionControllerUpdate(String id, UpdateInstitutionRequest updateInstitutionRequest,) async {
    final response = await institutionControllerUpdateWithHttpInfo(id, updateInstitutionRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Institution',) as Institution;
    
    }
    return null;
  }
}
