import 'package:sprout/account/models/account.dart';
import 'package:sprout/core/api/base.dart';
import 'package:sprout/core/models/finance_provider_config.dart';

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

  /// Returns accounts available to be added by the given provider
  Future<List<Account>> getProviderAccounts(FinanceProviderConfig provider) async {
    final endpoint = "/account/provider/get/all";
    final body = provider;
    final result = await client.post(body, endpoint) as List<dynamic>;
    return result.map((e) => Account.fromJson(e)).toList();
  }

  /// Links the given accounts for the given provider
  Future<List<Account>> linkProviderAccounts(FinanceProviderConfig provider, List<Account> accounts) async {
    final endpoint = "/account/provider/link";
    final body = {"provider": provider, "accounts": accounts.map((e) => e.toJson()).toList()};
    List result = await client.post(body, endpoint) as List<dynamic>;
    return (result).map((e) => Account.fromJson(e)).toList();
  }

  /// Manually runs a sync for new data
  Future<void> runManualSync() async {
    final endpoint = "/sync/manual";
    final body = {};
    await client.post(body, endpoint);
  }

  /// Tells the backend to remove a linked account
  Future<void> deleteAccount(Account account) async {
    final endpoint = "/account/delete";
    final body = account.toJson();
    await client.post(body, endpoint);
  }

  /// Updates the given account via the API
  Future<Account> edit(Account a) async {
    final endpoint = "/account/edit";
    final body = a.toJson();
    final result = await client.post(body, endpoint) as dynamic;
    return Account.fromJson(result);
  }
}
