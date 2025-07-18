import 'package:sprout/core/provider/base.dart';
import 'package:sprout/setup/api.dart';

/// Class that provides setup store information
class SetupProvider extends BaseProvider<SetupAPI> {
  SetupProvider(super.api);

  @override
  Future<void> onInit() async {}

  @override
  Future<void> onLogin() async {}

  @override
  Future<void> onLogout() async {}
}
