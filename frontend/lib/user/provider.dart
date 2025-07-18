import 'package:sprout/core/provider/base.dart';
import 'package:sprout/user/api.dart';

/// Class that provides user information
class UserProvider extends BaseProvider<UserAPI> {
  UserProvider(super.api);

  @override
  Future<void> onInit() async {}

  @override
  Future<void> onLogin() async {}

  @override
  Future<void> onLogout() async {}
}
