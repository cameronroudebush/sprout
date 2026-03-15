import 'package:http/http.dart' as http;
import 'package:sprout/api/api.dart';

/// A simple client for wrapping the [ApiClient] that allows us to set a base path
class BasePathClient extends ApiClient {
  String _basePath;
  final http.Client _innerClient;

  BasePathClient({required http.Client client, required super.basePath, super.authentication})
    : _basePath = basePath,
      _innerClient = client {
    this.client = _innerClient;
  }

  @override
  String get basePath => _basePath;

  set basePath(String newPath) {
    _basePath = newPath;
  }
}
