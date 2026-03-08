import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/account/models/account_state.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/sse_provider.dart';

part 'account_provider.g.dart';

/// Returns the authenticated API for the client
@Riverpod(keepAlive: true)
Future<AccountApi> accountApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return AccountApi(client);
}

@Riverpod(keepAlive: true)
class AccountList extends _$AccountList {
  @override
  Future<AccountState> build() async {
    ref.listen(sseProvider, (prev, next) {
      final data = next.value;
      if (data == null) return;

      if (data.event == SSEDataEventEnum.sync_) {
        final sync = ModelSync.fromJson(data.payload)!;

        // Update the global config for the "Last Synced" UI
        ref.read(secureConfigProvider.notifier).updateLastSync(sync);

        // Mark manual sync as finished and refresh the list
        state = AsyncData(state.value!.copyWith(manualSyncIsRunning: false));
        ref.invalidateSelf();
      }

      if (data.event == SSEDataEventEnum.forceUpdate) {
        ref.invalidateSelf();
      }
    });

    final api = await ref.watch(accountApiProvider.future);
    final accounts = await api.accountControllerGetAccounts() ?? [];

    accounts.sort((a, b) {
      final aIsLoan = a.type == AccountTypeEnum.loan;
      final bIsLoan = b.type == AccountTypeEnum.loan;
      if (aIsLoan != bIsLoan) return aIsLoan ? 1 : -1;
      return (b.balance).compareTo(a.balance);
    });

    return AccountState(accounts: accounts);
  }

  /// Runs a manual sync via the backend
  Future<void> manualSync() async {
    if (state.value == null) return;

    final notifications = ref.read(notificationsProvider.notifier);
    String? notificationId;

    try {
      state = AsyncData(state.value!.copyWith(manualSyncIsRunning: true));
      notificationId = notifications.openFrontendOnly("Account sync is running.", showSpinner: true);

      final api = await ref.read(accountApiProvider.future);
      await api.accountControllerManualSync(false);
    } catch (e) {
      state = AsyncData(state.value!.copyWith(manualSyncIsRunning: false));
      if (notificationId != null) notifications.clearOverlay(notificationId);
      notifications.openWithAPIException(e);
    }
  }

  /// Edits the given account via the backend
  Future<Account?> edit(Account a) async {
    final api = await ref.read(accountApiProvider.future);
    final updated = await api.accountControllerEdit(
      a.id,
      AccountEditRequest(name: a.name, subType: a.subType, interestRate: a.interestRate),
    );

    if (updated != null && state.value != null) {
      final newList = [...state.value!.accounts];
      final index = newList.indexWhere((r) => r.id == updated.id);
      if (index != -1) {
        newList[index] = updated;
        state = AsyncData(state.value!.copyWith(accounts: newList));
      }
    }
    return updated;
  }
}
