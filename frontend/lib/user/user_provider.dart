import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';

/// This provide allows for modification to the users via the API including authentication and creating new users.
class UserProvider extends BaseProvider<UserApi> {
  UserProvider(super.api);

  Future<String?> createUser(String username, String password) async {
    final response = await api.userControllerCreate(UserCreationRequest(username: username, password: password));
    return response?.username;
  }
}
