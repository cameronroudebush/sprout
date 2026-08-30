import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_details.dart';

/// Page specific to fetching and displaying transaction details
class TransactionDetailsPage extends ConsumerStatefulWidget {
  final String? transactionId;
  final bool disableNonEditable;

  const TransactionDetailsPage({
    super.key,
    this.transactionId,
    this.disableNonEditable = true,
  });

  @override
  ConsumerState<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends ConsumerState<TransactionDetailsPage> {
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _checkAndFetch();
  }

  @override
  void didUpdateWidget(covariant TransactionDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactionId != widget.transactionId) {
      _checkAndFetch();
    }
  }

  Future<void> _checkAndFetch() async {
    final id = widget.transactionId;
    if (id == null || id.isEmpty) return;

    final state = ref.read(transactionsProvider).value;
    final existsLocally = state?.transactions.any((t) => t.id == id) ?? false;

    if (!existsLocally) {
      setState(() => _isFetching = true);
      final item = await ref.read(transactionsProvider.notifier).fetchById(id);
      if (mounted) {
        setState(() => _isFetching = false);
        if (item == null) {
          NavigationProvider.redirect('/transactions');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);

    if (_isFetching) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: transactionsAsync.when(
        data: (state) {
          final transaction = state.transactions.firstWhereOrNull(
            (t) => t.id == widget.transactionId,
          );

          if (transaction == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) NavigationProvider.redirect('/transactions');
            });
            return const SizedBox.shrink();
          }

          return SproutRouteWrapper(
            child: TransactionDetailsView(
              transaction: transaction,
              disableNonEditable: widget.disableNonEditable,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
