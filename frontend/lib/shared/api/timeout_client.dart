import 'package:http/http.dart' as http;

/// A simple client wrapper that enforces a timeout on every request
class TimeoutClient extends http.BaseClient {
  final http.Client innerClient;

  /// How long to wait for a failure from a timeout, in seconds
  final int timeout;

  TimeoutClient({required this.innerClient, required this.timeout});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return innerClient
        .send(request)
        .timeout(
          Duration(seconds: timeout),
          onTimeout: () => throw http.ClientException('Request timed out after $timeout seconds', request.url),
        );
  }
}
