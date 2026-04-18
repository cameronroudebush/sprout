import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:http/http.dart' as http;

/// An extension for our api clients that allows cookies to be automatically handled for mobile
class CookieClient extends http.BaseClient {
  final http.Client innerClient;
  final CookieJar cookieJar;

  CookieClient({required this.innerClient, required this.cookieJar});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Load cookies from Jar and add to Request
    final cookies = await cookieJar.loadForRequest(request.url);
    if (cookies.isNotEmpty) {
      request.headers[HttpHeaders.cookieHeader] = cookies.map((c) => '${c.name}=${c.value}').join('; ');
    }

    final response = await innerClient.send(request);

    // Extract and parse Set-Cookie headers
    final setCookieHeader = response.headers[HttpHeaders.setCookieHeader];
    if (setCookieHeader != null) {
      // Logic to handle multiple cookies and Case-Sensitivity
      final List<Cookie> parsedCookies = _parseRawSetCookie(setCookieHeader);
      await cookieJar.saveFromResponse(request.url, parsedCookies);
    }

    return response;
  }

  /// Parses raw set cookie header into cookies formatted for the CookieJar
  List<Cookie> _parseRawSetCookie(String header) {
    return header
        .split(RegExp(r',(?=[^;]+?=)'))
        .map((s) {
          try {
            // Before passing to Dart's strict parser, we fix the case of common attributes
            String fixed = s
                .replaceAll('samesite=strict', 'SameSite=Strict')
                .replaceAll('samesite=lax', 'SameSite=Lax')
                .replaceAll('httponly', 'HttpOnly');

            return Cookie.fromSetCookieValue(fixed);
          } catch (e) {
            return null;
          }
        })
        .whereType<Cookie>()
        .toList();
  }
}
