import 'package:sprout/api/api.dart';

/// Represents the account state tracker for our riverpod
class AccountState {
  final List<Account> accounts;
  final bool manualSyncIsRunning;

  AccountState({required this.accounts, this.manualSyncIsRunning = false});

  AccountState copyWith({List<Account>? accounts, bool? manualSyncIsRunning}) {
    return AccountState(
      accounts: accounts ?? this.accounts,
      manualSyncIsRunning: manualSyncIsRunning ?? this.manualSyncIsRunning,
    );
  }
}
