import 'package:sprout/core/api/client.dart';
import 'package:sprout/core/api/storage.dart';

/// This class provides the basic capabilities for API's across Sprout.
class BaseAPI {
  /// The rest client to be able to communicate with the backend
  final RESTClient client;

  /// Storage to use for important data that may be stored from the API calls
  final SecureStorage secureStorage = SecureStorage();
  BaseAPI(this.client);
}
