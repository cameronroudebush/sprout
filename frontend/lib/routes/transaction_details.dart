import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_details.dart';

/// Page specific to fetching and displaying transaction details
class TransactionDetailsPage extends ConsumerWidget {
  final String? transactionId;
  final bool disableNonEditable;

  const TransactionDetailsPage({
    super.key,
    this.transactionId,
    this.disableNonEditable = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = transactionId;
    if (id == null || id.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavigationProvider.redirect('/transactions');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final transactionAsync = ref.watch(transactionByIdProvider(id));

    return Scaffold(
      body: transactionAsync.when(
        data: (transaction) {
          if (transaction == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) NavigationProvider.redirect('/transactions');
            });
            return const SizedBox.shrink();
          }

          return SproutRouteWrapper(
            child: TransactionDetailsView(
              transaction: transaction,
              disableNonEditable: disableNonEditable,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
