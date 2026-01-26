import 'package:http/http.dart' as http;
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/core/provider/service.locator.dart';

/// An interceptor that attempts to refresh access tokens as needed on failures.
class AuthInterceptor extends http.BaseClient {
  final http.Client _inner;

  AuthInterceptor({required http.Client innerClient}) : _inner = innerClient;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final authProvider = ServiceLocator.get<AuthProvider>();
    // Attach current headers
    final headers = await authProvider.getHeaders();
    request.headers.addAll(headers);

    // Send the request
    var response = await _inner.send(request);

    // If 401 Unauthorized, try to refresh
    if (response.statusCode == 401) {
      final success = await authProvider.silentRefresh();

      if (success) {
        // Re-create the request with new tokens
        final newHeaders = await authProvider.getHeaders();
        final newRequest = _copyRequest(request);
        newRequest.headers.addAll(newHeaders);
        return _inner.send(newRequest);
      }
    }

    return response;
  }

  // Helper to clone requests for retries
  http.BaseRequest _copyRequest(http.BaseRequest request) {
    if (request is http.Request) {
      final copy = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..bodyBytes = request.bodyBytes
        ..followRedirects = request.followRedirects
        ..persistentConnection = request.persistentConnection;
      return copy;
    }
    return request;
  }
}
