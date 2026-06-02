import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/header.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';

/// Renders the recent number of transactions in a card intended for the dashboard
class DashboardRecentTransactionsCard extends ConsumerWidget {
  /// How many recent transactions we want
  final int count;

  /// Whether the widget is rendering on a mobile screen context
  final bool mobile;

  const DashboardRecentTransactionsCard({super.key, this.count = 10, this.mobile = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    Widget content = transactionsAsync.whenDefault(
      expanded: false,
      customErrorMessage: "Failed to load transactions",
      emptyCondition: (state) => state.transactions.isEmpty,
      data: (state) {
        final recent = state.transactions.take(count).toList();

        return ListView.separated(
          shrinkWrap: mobile,
          physics: mobile ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
          itemCount: recent.length,
          separatorBuilder: (_, __) => const SizedBox(height: 0),
          itemBuilder: (context, index) {
            return TransactionRow(recent[index]);
          },
        );
      },
    );

    return SproutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: mobile ? MainAxisSize.min : MainAxisSize.max,
        spacing: 4,
        children: [
          ChartHeader(
            title: "Recent Activity",
          ),
          mobile ? content : Expanded(child: content),
        ],
      ),
    );
  }
}
