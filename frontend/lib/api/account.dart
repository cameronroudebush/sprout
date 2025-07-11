import 'package:event_bus/event_bus.dart';
import 'package:sprout/api/client.dart';
import 'package:sprout/model/account.dart';

/// Class that provides callable endpoints for the accounts
class AccountAPI {
  /// Base URL of the sprout backend API
  RESTClient client;

  AccountAPI(this.client);

  /// Fired whenever accounts are updated
  final accountsUpdated = EventBus();

  /// Returns the accounts
  Future<dynamic> getAccounts() async {
    final endpoint = "/account/get/all";
    final body = {};

    try {
      List result = await client.post(body, endpoint) as List<dynamic>;
      return (result).map((e) => Account.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Returns accounts that can be added
  Future<dynamic> getProviderAccounts() async {
    final endpoint = "/account/provider/get/all";
    final body = {};

    try {
      List result = await client.post(body, endpoint) as List<dynamic>;
      return (result).map((e) => Account.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Returns accounts that can be added
  Future<dynamic> linkProviderAccounts(List<Account> accounts) async {
    final endpoint = "/account/provider/link";
    final body = accounts.map((e) => e.toJson()).toList();

    try {
      List result = await client.post(body, endpoint) as List<dynamic>;
      print(result);
      return false;
      // return (result).map((e) => Account.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
