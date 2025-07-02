// lib/api/jwt_api_client.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// A client for interacting with a REST API that uses JWT for authentication.
class JwtApiClient {
  /// Base URL of your backend API (e.g., 'http://192.168.1.10:8080/api')
  final String baseUrl;
  // Secure storage instance for storing the JWT token.
  final _storage = const FlutterSecureStorage();
  // Key used to store the JWT token in secure storage.
  static const String _jwtKey = 'jwt_token';

  /// Constructor for JwtApiClient.
  /// [baseUrl] The base URL of your backend API.
  JwtApiClient(this.baseUrl);

  /// Saves the JWT token securely to the device.
  Future<void> _saveToken(String token) async {
    await _storage.write(key: _jwtKey, value: token);
  }

  /// Retrieves the JWT token from secure storage.
  /// Returns the token string if found, otherwise null.
  Future<String?> _getToken() async {
    return await _storage.read(key: _jwtKey);
  }

  /// Deletes the JWT token from secure storage.
  /// This should be called on logout or when the token is invalid.
  Future<void> deleteToken() async {
    await _storage.delete(key: _jwtKey);
  }

  /// Authenticates a user with the backend API.
  /// Sends username and password to the login endpoint and stores the received JWT.
  /// [username] The user's username.
  /// [password] The user's password.
  /// Returns true if login is successful and token is stored, false otherwise.
  Future<bool> login(String username, String password) async {
    // Construct the URL for the login endpoint. Adjust '/auth/login' as per your API.
    final url = Uri.parse('$baseUrl/user/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Assuming your API returns the JWT in a field named 'token'.
        // Adjust 'token' if your API uses a different field name (e.g., 'accessToken').
        final token = data['token'];
        if (token != null) {
          await _saveToken(token);
          return true;
        }
        return false;
      } else {
        // Log the error for debugging purposes.
        print('Login failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      // Catch any network or parsing errors.
      print('Error during login: $e');
      return false;
    }
  }

  /// Makes an authenticated GET request to the specified endpoint.
  /// Retrieves the stored JWT and attaches it to the 'Authorization' header.
  /// [endpoint] The API endpoint to call (e.g., 'profile', 'users/123').
  /// Returns the HTTP response.
  /// Throws an Exception if no token is found or if the token is unauthorized (401).
  Future<http.Response> get(String endpoint) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No JWT token found. User not logged in.');
    }

    // Construct the full URL for the request.
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Attach the JWT to the Authorization header in 'Bearer <token>' format.
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      // If the token is unauthorized (e.g., expired or invalid), clear it from storage.
      await deleteToken();
      throw Exception(
        'Unauthorized: Token expired or invalid. Please re-login.',
      );
    }
    return response;
  }

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
