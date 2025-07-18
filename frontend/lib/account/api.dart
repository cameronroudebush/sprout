import 'package:sprout/account/models/account.dart';
import 'package:sprout/core/api/base.dart';

/// Class that provides callable endpoints for the accounts
class AccountAPI extends BaseAPI {
  AccountAPI(super.client);

  /// Returns the accounts
  Future<List<Account>> getAccounts() async {
    final endpoint = "/account/get/all";
    final body = {};
    List result = await client.post(body, endpoint) as List<dynamic>;
    return (result).map((e) => Account.fromJson(e)).toList();
  }

  /// Returns accounts that can be added
  Future<List<Account>> getProviderAccounts() async {
    final endpoint = "/account/provider/get/all";
    final body = {};
    List result = await client.post(body, endpoint) as List<dynamic>;
    return (result).map((e) => Account.fromJson(e)).toList();
  }

  /// Returns accounts that can be added
  Future<List<Account>> linkProviderAccounts(List<Account> accounts) async {
    final endpoint = "/account/provider/link";
    final body = accounts.map((e) => e.toJson()).toList();
    List result = await client.post(body, endpoint) as List<dynamic>;
    return (result).map((e) => Account.fromJson(e)).toList();
  }
}
