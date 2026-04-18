import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/models/extensions/date_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/transaction/models/transaction_state.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';
import 'package:sprout/transaction/widgets/transactions_filter_bar.dart';

/// A page that allows displaying all transactions, or ones given by a specific account
class TransactionsPage extends ConsumerStatefulWidget {
  /// Allows filtering transactions to a specific account
  final String? accountId;
  final bool allowFiltering;
  final bool separateByDate;

  /// Padding to apply around this page
  final EdgeInsetsGeometry padding;

  const TransactionsPage({
    super.key,
    this.accountId,
    this.allowFiltering = true,
    this.separateByDate = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
  });

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  final ScrollController _scrollController = ScrollController();
  int _filteredOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      final catId = state.uri.queryParameters['categoryId'];

      ref.read(transactionFilterStateProvider.notifier).update(
            TransactionFilter(accountId: widget.accountId, categoryId: catId ?? CategoryDropdown.fakeAllCategory.id),
          );

      _fetchPage();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Fetches the content that needs based on our current filter
  Future<void> _fetchPage({bool reset = false}) async {
    final filters = ref.read(transactionFilterStateProvider);
    await ref.read(transactionsProvider.notifier).fetchFilteredPage(
          startIndex: reset ? 0 : _filteredOffset,
          accountId: filters.accountId,
          catId: filters.categoryId,
          search: filters.search,
          dateRange: filters.dateRange,
          pending: filters.pending,
        );
  }

  /// What to do as we scroll down the page
  void _onScroll() {
    final state = ref.read(transactionsProvider).value;
    if (state == null || state.isLoadingMore || state.hasReachedMax) return;

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _filteredOffset += Transactions.pageSize;
      _fetchPage(); // Append next page
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final masterAsync = ref.watch(transactionsProvider);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);

    return Column(
      children: [
        if (widget.allowFiltering)
          Container(
            width: double.infinity,
            color: theme.scaffoldBackgroundColor,
            child: SproutRouteWrapper(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: TransactionFilterBar(
                accountId: widget.accountId,
                onFilterChanged: () => _fetchPage(),
              ),
            ),
          ),
        Expanded(
          child: masterAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text("Error: $err")),
            data: (masterState) {
              if (filteredTransactions.isEmpty && !masterState.isLoadingMore) {
                return const Center(child: Text("No matching transactions found."));
              }

              return RefreshIndicator(
                onRefresh: () async => await _fetchPage(reset: true),
                child: widget.separateByDate
                    ? _buildGroupedList(filteredTransactions, masterState.isLoadingMore, theme)
                    : _buildSingleList(filteredTransactions, masterState.isLoadingMore),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the grouped lists based on the date of a transaction
  Widget _buildGroupedList(List<dynamic> transactions, bool isLoadingMore, ThemeData theme) {
    final grouped = transactions.groupListsBy((t) => DateTime(t.posted.year, t.posted.month, t.posted.day));

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: grouped.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == grouped.length) {
          return const SproutRouteWrapper(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final date = grouped.keys.elementAt(index);
        final dayTransactions = grouped.values.elementAt(index);

        return SproutRouteWrapper(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4, top: 12),
                child: Text(date.toShortMonth, style: theme.textTheme.titleSmall),
              ),
              SproutCard(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dayTransactions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, tIndex) => TransactionRow(dayTransactions[tIndex]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a single list of transactions if we don't wish to separate by date
  Widget _buildSingleList(List<dynamic> transactions, bool isLoadingMore) {
    return SproutCard(
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: transactions.length + (isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == transactions.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return TransactionRow(transactions[index]);
        },
      ),
    );
  }
}
