/// Helper stub for authenticating via OIDC for the login process
class OIDCHelper {
  /// Checks if the current session was started by a Web OIDC callback and grabs the tokens.
  Map<String, String>? getWebCallbackTokens() => throw UnimplementedError();

  /// Initiates the full OIDC login flow
  Future<Map<String, String>?> authenticate({
    required String issuerUrl,
    required String clientId,
    required List<String> scopes,
  }) async => throw UnimplementedError();
}
