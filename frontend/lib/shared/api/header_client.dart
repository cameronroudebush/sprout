import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// An extended client that applies header information dynamically
class HeaderClient extends http.BaseClient {
  final http.Client _inner;

  HeaderClient({required http.Client innerClient}) : _inner = innerClient;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Apply platform headers
    if (kIsWeb) {
      request.headers.addAll({'x-client-platform': 'web'});
    } else {
      request.headers.addAll({'x-client-platform': 'mobile'});
    }

    var response = await _inner.send(request);
    return response;
  }
}
