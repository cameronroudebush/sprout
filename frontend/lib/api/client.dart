// lib/api/jwt_api_client.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sprout/api/storage.dart';
import 'package:sprout/api/user.dart';
import 'package:uuid/uuid.dart';

/// A client for interacting with a REST API that uses JWT for authentication.
class RESTClient {
  /// Base URL of the sprout backend API
  final String baseUrl;

  /// Storage to use with the REST API's
  final SecureStorage secureStorage = SecureStorage();

  /// Constructor for RESTClient.
  /// [baseUrl] The base URL of the backend API.
  RESTClient(this.baseUrl);

  Future<Map<String, String>> _getSendHeaders() async {
    String? jwt = await this.secureStorage.getValue(UserAPI.jwtKey);
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
    final url = Uri.parse('$baseUrl$endpoint');
    // We must create body that follows the backend structure
    final Object body = {
      'payload': payload,
      'requestId': Uuid().v4(),
      'timeStamp': DateTime.timestamp().toIso8601String(),
    };

    final response = await http.post(
      url,
      headers: await _getSendHeaders(),
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["payload"];
    } else {
      throw Exception(
        'Failed to post to $endpoint: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Makes a get request to the given endpoint
  /// [endpoint] The endpoint to post to. Must start with a /
  Future<Object> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await http.get(url, headers: await _getSendHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["payload"];
    } else {
      throw Exception(
        'Failed to post to $endpoint: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // /// Makes an authenticated GET request to the specified endpoint.
  // /// Retrieves the stored JWT and attaches it to the 'Authorization' header.
  // /// [endpoint] The API endpoint to call (e.g., 'profile', 'users/123').
  // /// Returns the HTTP response.
  // /// Throws an Exception if no token is found or if the token is unauthorized (401).
  // Future<http.Response> get(String endpoint) async {
  //   final token = await _getToken();
  //   if (token == null) {
  //     throw Exception('No JWT token found. User not logged in.');
  //   }

  //   // Construct the full URL for the request.
  //   final url = Uri.parse('$baseUrl/$endpoint');
  //   final response = await http.get(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       // Attach the JWT to the Authorization header in 'Bearer <token>' format.
  //       'Authorization': 'Bearer $token',
  //     },
  //   );

  //   if (response.statusCode == 401) {
  //     // If the token is unauthorized (e.g., expired or invalid), clear it from storage.
  //     await deleteToken();
  //     throw Exception(
  //       'Unauthorized: Token expired or invalid. Please re-login.',
  //     );
  //   }
  //   return response;
  // }

  // /// Example of an authenticated API call to fetch user profile data.
  // /// Calls the generic `get` method with the 'profile' endpoint.
  // /// Returns a map of profile data if successful, otherwise null.
  // Future<Map<String, dynamic>?> getProfile() async {
  //   try {
  //     // Adjust 'profile' to your actual profile endpoint.
  //     final response = await get('profile');
  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       print('Failed to load profile: ${response.statusCode} - ${response.body}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Error fetching profile: $e');
  //     return null;
  //   }
  // }
}
