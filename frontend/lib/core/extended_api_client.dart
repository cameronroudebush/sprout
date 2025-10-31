import 'package:sprout/api/api.dart';

/// An extended ApiClient that allows for changing the base path dynamically.
class ExtendedApiClient extends ApiClient {
  String _basePath;

  ExtendedApiClient({required super.basePath, super.authentication}) : _basePath = basePath;

  @override
  String get basePath => _basePath;

  /// Updates the base path for all future API calls.
  set basePath(String newPath) {
    _basePath = newPath;
  }
}
