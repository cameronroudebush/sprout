//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class WebhookApi {
  WebhookApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Handle plaid update webhook
  ///
  /// Used to listen for responses from plaid to trigger automatic account syncs. This allows out-of-band syncing, not requiring a job to perform the update.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> plaidWebhookControllerHandlePlaidWebhookWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/webhooks/plaid';

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

  /// Handle plaid update webhook
  ///
  /// Used to listen for responses from plaid to trigger automatic account syncs. This allows out-of-band syncing, not requiring a job to perform the update.
  Future<void> plaidWebhookControllerHandlePlaidWebhook() async {
    final response = await plaidWebhookControllerHandlePlaidWebhookWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Bulk update all registered Plaid webhooks
  ///
  /// Iterates through all database items and pushes the updated webhook destination url to Plaid's servers. This is useful if you change where your server is located.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [PlaidWebhookControllerMigrateWebhookUrlsRequest] plaidWebhookControllerMigrateWebhookUrlsRequest (required):
  Future<Response> plaidWebhookControllerMigrateWebhookUrlsWithHttpInfo(PlaidWebhookControllerMigrateWebhookUrlsRequest plaidWebhookControllerMigrateWebhookUrlsRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/webhooks/plaid/migrate-url';

    // ignore: prefer_final_locals
    Object? postBody = plaidWebhookControllerMigrateWebhookUrlsRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Bulk update all registered Plaid webhooks
  ///
  /// Iterates through all database items and pushes the updated webhook destination url to Plaid's servers. This is useful if you change where your server is located.
  ///
  /// Parameters:
  ///
  /// * [PlaidWebhookControllerMigrateWebhookUrlsRequest] plaidWebhookControllerMigrateWebhookUrlsRequest (required):
  Future<void> plaidWebhookControllerMigrateWebhookUrls(PlaidWebhookControllerMigrateWebhookUrlsRequest plaidWebhookControllerMigrateWebhookUrlsRequest,) async {
    final response = await plaidWebhookControllerMigrateWebhookUrlsWithHttpInfo(plaidWebhookControllerMigrateWebhookUrlsRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
