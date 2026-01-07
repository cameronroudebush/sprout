import 'dart:async';

import 'package:http/http.dart' as http;

/// This client is used to allow us to fire an auto logout if we send messages and we receive errors related to them
class AutoLogoutClient extends http.BaseClient {
  final http.Client _inner;
  final void Function() onLogout;

  get client => _inner;

  AutoLogoutClient({http.Client? inner, required this.onLogout}) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);
    if (response.statusCode == 403 || response.statusCode == 401) onLogout();
    return response;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
