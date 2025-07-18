// lib/api/jwt_api_client.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sprout/auth/api.dart';
import 'package:sprout/core/api/storage.dart';
import 'package:uuid/uuid.dart';

/// A client for interacting with a REST API that uses JWT for authentication.
class RESTClient {
  /// Base URL of the sprout backend API
  final String _baseUrl;
  String get _apiUrl => "$_baseUrl/api";

  /// Storage to use with the REST API's
  final SecureStorage secureStorage = SecureStorage();

  /// Constructor for RESTClient.
  /// [baseUrl] The base URL of the backend API.
  RESTClient(this._baseUrl);

  Future<Map<String, String>> _getSendHeaders() async {
    String? jwt = await this.secureStorage.getValue(AuthAPI.jwtKey);
    final headers = {'Content-Type': 'application/json'};
    if (jwt != null && jwt.isNotEmpty) {
      headers['Authorization'] = 'Bearer $jwt';
    }
    return headers;
  }

  /// Posts the requested body content to the given endpoint
  /// [payload] The content to stringify and send as a payload
  /// [endpoint] The endpoint to post to. Must start with a /
  Future<Object> post(dynamic payload, String endpoint) async {
    final url = Uri.parse('$_apiUrl$endpoint');
    // We must create body that follows the backend structure
    final Object body = {
      'payload': payload,
      'requestId': Uuid().v4(),
      'timeStamp': DateTime.timestamp().toIso8601String(),
    };

    final response = await http.post(url, headers: await _getSendHeaders(), body: json.encode(body));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["payload"];
    } else {
      throw Exception('Failed to post to $endpoint: ${response.statusCode} - ${response.body}');
    }
  }

  /// Makes a get request to the given endpoint
  /// [endpoint] The endpoint to post to. Must start with a /
  Future<Object> get(String endpoint) async {
    final url = Uri.parse('$_apiUrl$endpoint');

    final response = await http.get(url, headers: await _getSendHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["payload"];
    } else {
      throw Exception('Failed to get to $endpoint: ${response.statusCode} - ${response.body}');
    }
  }
}
