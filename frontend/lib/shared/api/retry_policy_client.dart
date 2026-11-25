import 'package:http/http.dart' as http;

/// Matches requests that must skip the retrying HTTP client.
class NoRetryRequestRule {
  const NoRetryRequestRule({
    required this.method,
    required this.pathSuffix,
  });

  final String method;
  final List<String> pathSuffix;

  bool matches(http.BaseRequest request) {
    if (request.method.toUpperCase() != method.toUpperCase()) return false;

    final pathSegments = request.url.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (pathSegments.length < pathSuffix.length) return false;

    final suffixOffset = pathSegments.length - pathSuffix.length;
    for (var i = 0; i < pathSuffix.length; i++) {
      if (pathSegments[suffixOffset + i] != pathSuffix[i]) return false;
    }

    return true;
  }
}

/// Routes excluded requests directly, while sending all others through retries.
class RetryPolicyClient extends http.BaseClient {
  RetryPolicyClient({
    required http.Client retryClient,
    required http.Client innerClient,
    required List<NoRetryRequestRule> noRetryRules,
  })  : _retryClient = retryClient,
        _innerClient = innerClient,
        _noRetryRules = noRetryRules;

  final http.Client _retryClient;
  final http.Client _innerClient;
  final List<NoRetryRequestRule> _noRetryRules;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (_noRetryRules.any((rule) => rule.matches(request))) {
      return _innerClient.send(request);
    }

    return _retryClient.send(request);
  }

  @override
  void close() => _retryClient.close();
}
