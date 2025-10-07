// lib/api/jwt_api_client.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:sprout/auth/api.dart';
import 'package:sprout/auth/provider.dart';
import 'package:sprout/core/api/storage.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/snackbar.dart';
import 'package:uuid/uuid.dart';

/// A client for interacting with a REST API that uses JWT for authentication.
class RESTClient {
  // Key used to store the connection url in storage so we know where we're connecting.
  static const String connectionUrlKey = 'connection_url';

  final timeout = kDebugMode ? Duration(seconds: 10) : Duration(seconds: 30);
  final client = Client();

  /// Base URL of the sprout backend API
  String? _baseUrl;
  // Returns the base URL without any API addition
  String? get baseUrl => _baseUrl;

  /// Returns the base URL + the API path
  String get apiUrl => "$_baseUrl/api";

  /// Storage to use with the REST API's
  final SecureStorage _secureStorage = SecureStorage();

  SecureStorage get secureStorage => _secureStorage;

  void dispose() {
    client.close();
  }

  /// Returns if we have a connection URL or not
  bool hasConnectionUrl() {
    return _baseUrl != null;
  }

  /// Sets the base URL for the client so other API's can access what the base URL should be
  Future<String?> setBaseUrl() async {
    if (kIsWeb) {
      // Web can base connections on the uri of the current connection
      Uri uri = Uri.base;
      final leading = '${uri.scheme}://${uri.host}';
      _baseUrl = kDebugMode ? '$leading:8001' : leading;
    } else {
      // Apps must specify the connection URL so we know where to look
      _baseUrl = await _secureStorage.getValue(RESTClient.connectionUrlKey);
    }
    return _baseUrl;
  }

  Future<Map<String, String>> getSendHeaders() async {
    String? jwt = await _secureStorage.getValue(AuthAPI.jwtKey);
    final headers = {'Content-Type': 'application/json'};
    if (jwt != null && jwt.isNotEmpty) {
      headers['Authorization'] = 'Bearer $jwt';
    }
    return headers;
  }

  /// Checks if the response included an unauthorized response and logs out if so.
  Future<void> _checkUnauth(Response response) async {
    if (response.statusCode == 403) {
      final authProvider = ServiceLocator.get<AuthProvider>();
      if (authProvider.isLoggedIn) {
        await authProvider.logout(forced: true);
        SnackbarProvider.openSnackbar("Session expired", type: SnackbarType.warning);
      }
    }
  }

  /// Posts the requested body content to the given endpoint
  /// [payload] The content to stringify and send as a payload
  /// [endpoint] The endpoint to post to. Must start with a /
  Future<Object> post(dynamic payload, String endpoint) async {
    final url = Uri.parse('$apiUrl$endpoint');
    // We must create body that follows the backend structure
    final Object body = {
      'payload': payload,
      'requestId': Uuid().v4(),
      'timeStamp': DateTime.timestamp().toIso8601String(),
    };

    final response = await client.post(url, headers: await getSendHeaders(), body: json.encode(body)).timeout(timeout);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["payload"];
    } else {
      _checkUnauth(response);
      SnackbarProvider.openSnackbar('Request failed: ${response.body}', type: SnackbarType.error);
      throw Exception('Failed to post to $endpoint: ${response.statusCode} - ${response.body}');
    }
  }

  /// Makes a get request to the given endpoint
  /// [endpoint] The endpoint to post to. Must start with a /
  Future<Object> get(String endpoint) async {
    final url = Uri.parse('$apiUrl$endpoint');

    final response = await client.get(url, headers: await getSendHeaders()).timeout(timeout);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["payload"];
    } else {
      _checkUnauth(response);
      SnackbarProvider.openSnackbar('Request failed: ${response.body}', type: SnackbarType.error);
      throw Exception('Failed to get to $endpoint: ${response.statusCode} - ${response.body}');
    }
  }
}
