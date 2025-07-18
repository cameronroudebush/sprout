import 'package:sprout/account/api.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/core/provider/base.dart';

/// Class that provides the store of current account information
class AccountProvider extends BaseProvider<AccountAPI> {
  // Data store
  List<Account> _linkedAccounts = [];

  // Getters to not allow editing the internal store
  List<Account> get linkedAccounts => _linkedAccounts;

  AccountProvider(super.api);

  Future<List<Account>> populateLinkedAccounts() async {
    _linkedAccounts = await api.getAccounts();
    notifyListeners();
    return _linkedAccounts;
  }

  @override
  Future<void> onLogin() async {
    await populateLinkedAccounts();
  }

  @override
  Future<void> onLogout() async {
    _linkedAccounts = [];
    notifyListeners();
  }

  @override
  Future<void> onInit() async {}
}
