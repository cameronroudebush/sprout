import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_details.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/routes/util/navigation_provider.dart';

/// Page specific to display account details
class AccountDetailsPage extends ConsumerWidget {
  final String? accountId;

  const AccountDetailsPage({super.key, this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      body: accountsAsync.when(
        data: (state) {
          final account = state.accounts.firstWhereOrNull(
            (a) => a.id == accountId,
          );

          if (account == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) NavigationProvider.redirect('/accounts');
            });

            return const SizedBox.shrink();
          }

          return SproutRouteWrapper(
            child: AccountDetailsView(account: account),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
