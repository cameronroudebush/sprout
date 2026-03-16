import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/config/config_provider.dart';

/// An interceptor that attempts to refresh access tokens as needed on failures using Riverpod.
class AuthInterceptorClient extends http.BaseClient {
  final http.Client _inner;
  final Ref _ref;

  AuthInterceptorClient({required http.Client innerClient, required Ref ref}) : _inner = innerClient, _ref = ref;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final authNotifier = _ref.read(authProvider.notifier);
    final isOIDCAuthMode = _ref.read(unsecureConfigProvider.notifier).isOIDCAuthMode;
    final headers = await authNotifier.getHeaders();
    request.headers.addAll(headers);
    var response = await _inner.send(request);

    // If 401 Unauthorized, attempt a silent refresh
    if (response.statusCode == 401 && isOIDCAuthMode) {
      // Trigger the refresh logic in your AuthNotifier
      final success = await authNotifier.silentRefresh();

      if (success) {
        // Re-create the request with new tokens
        final newHeaders = await authNotifier.getHeaders();
        final newRequest = _copyRequest(request);
        newRequest.headers.addAll(newHeaders);

        return _inner.send(newRequest);
      }
    }

    return response;
  }

  /// Helper to clone requests for retries
  http.BaseRequest _copyRequest(http.BaseRequest request) {
    if (request is http.Request) {
      final copy = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..bodyBytes = request.bodyBytes
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..persistentConnection = request.persistentConnection;
      return copy;
    }
    // Handle multipart or streamed requests if necessary
    return request;
  }
}
