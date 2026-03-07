import 'package:http/http.dart';

class AutoLogoutClient extends BaseClient {
  final Client _inner;
  final Future<void> Function() onLogout;

  AutoLogoutClient({required Client innerClient, required this.onLogout}) : _inner = innerClient;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    // Send the request to the inner client
    final response = await _inner.send(request);

    // If the inner client failed, force the logout
    if (response.statusCode == 401 || response.statusCode == 403) {
      await onLogout();
    }

    return response;
  }
}
