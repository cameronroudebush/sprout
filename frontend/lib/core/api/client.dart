// lib/api/jwt_api_client.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sprout/auth/api.dart';
import 'package:sprout/auth/provider.dart';
import 'package:sprout/core/api/storage.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/snackbar.dart';
import 'package:uuid/uuid.dart';

/// A client for interacting with a REST API that uses JWT for authentication.
class RESTClient {
  /// Base URL of the sprout backend API
  final String _baseUrl = RESTClient.getBaseURL();
  String get apiUrl => "$_baseUrl/api";

  /// Storage to use with the REST API's
  final SecureStorage _secureStorage = SecureStorage();

  /// Returns the base URL that the backend should be expected to be running on. This will not include
  ///   any potential sub-pathing.
  static String getBaseURL() {
    Uri uri = Uri.base;
    final leading = '${uri.scheme}://${uri.host}';
    return kDebugMode ? '$leading:8001' : leading;
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
  Future<void> _checkUnauth(http.Response response) async {
    if (response.statusCode == 403) {
      final authProvider = ServiceLocator.get<AuthProvider>();
      if (authProvider.isLoggedIn) {
        await authProvider.logout();
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

    final response = await http.post(url, headers: await getSendHeaders(), body: json.encode(body));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["payload"];
    } else {
      _checkUnauth(response);
      throw Exception('Failed to post to $endpoint: ${response.statusCode} - ${response.body}');
    }
  }

  /// Makes a get request to the given endpoint
  /// [endpoint] The endpoint to post to. Must start with a /
  Future<Object> get(String endpoint) async {
    final url = Uri.parse('$apiUrl$endpoint');

    final response = await http.get(url, headers: await getSendHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["payload"];
    } else {
      _checkUnauth(response);
      throw Exception('Failed to get to $endpoint: ${response.statusCode} - ${response.body}');
    }
  }
}
