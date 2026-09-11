import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/models/extensions/date_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/transaction/models/transaction_state.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';
import 'package:sprout/transaction/widgets/transactions_filter_bar.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  final String? accountId;
  final bool allowFiltering;
  final bool separateByDate;
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
  TransactionFilter? _localFilter;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Gets the current filter based on the route params
  TransactionFilter _getFilterFromRoute(BuildContext context) {
    final routeState = GoRouterState.of(context);
    final params = routeState.uri.queryParameters;

    final search = params['search'] ?? '';
    final categoryId = params['categoryId'] ?? CategoryDropdown.fakeAllCategory.id;
    final accountId = params['accountId'] ?? widget.accountId;

    bool? pending;
    if (params['pending'] != null) {
      pending = params['pending'] == 'true';
    }

    DateTimeRange? dateRange;
    if (params['startDate'] != null && params['endDate'] != null) {
      final start = DateTime.tryParse(params['startDate']!);
      final end = DateTime.tryParse(params['endDate']!);
      if (start != null && end != null) {
        dateRange = DateTimeRange(start: start, end: end);
      }
    }

    return TransactionFilter(
      search: search,
      accountId: accountId,
      categoryId: categoryId,
      pending: pending,
      dateRange: dateRange,
    );
  }

  TransactionFilter _effectiveFilter(BuildContext context) {
    return _localFilter ?? _getFilterFromRoute(context);
  }

  /// What to do when the filter values change, related to the query params
  void _onFilterChanged(TransactionFilter newFilter, bool updateUrlParams) {
    if (updateUrlParams) {
      final queryParams = <String, String>{};
      if (newFilter.search.isNotEmpty) queryParams['search'] = newFilter.search;
      if (newFilter.accountId != null) queryParams['accountId'] = newFilter.accountId!;
      if (newFilter.categoryId != null && newFilter.categoryId != CategoryDropdown.fakeAllCategory.id) {
        queryParams['categoryId'] = newFilter.categoryId!;
      }
      if (newFilter.pending != null) {
        queryParams['pending'] = newFilter.pending.toString();
      }
      if (newFilter.dateRange != null) {
        queryParams['startDate'] = newFilter.dateRange!.start.toIso8601String();
        queryParams['endDate'] = newFilter.dateRange!.end.toIso8601String();
      }

      final currentUri = GoRouterState.of(context).uri;

      // Rebuild Uri cleanly from path to guarantee omitted query keys (like pending) are destroyed
      final newUri = Uri(
        path: currentUri.path,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      context.go(newUri.toString());
    } else {
      setState(() {
        _localFilter = newFilter;
      });
    }
  }

  void _onScroll() {
    if (_isFetching || !_scrollController.hasClients) return;

    final filter = _effectiveFilter(context);
    final state = ref.read(transactionsProvider(filter)).value;
    if (state == null || state.isLoadingMore || state.hasReachedMax) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= 150) {
      _isFetching = true;
      ref.read(transactionsProvider(filter).notifier).fetchNextPage().whenComplete(() {
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = _effectiveFilter(context);
    final masterAsync = ref.watch(transactionsProvider(filter));

    return SproutLayoutBuilder(
      (isDesktop, context, constraints) {
        return Column(
          children: [
            if (widget.allowFiltering)
              Container(
                width: double.infinity,
                color: theme.scaffoldBackgroundColor,
                child: SproutRouteWrapper(
                  padding: EdgeInsets.fromLTRB(16, isDesktop ? 0 : 12, 16, 0),
                  child: TransactionFilterBar(
                    filter: filter,
                    onFilterChanged: _onFilterChanged,
                    // Only use URL params if this is a main display of this
                    updateUrlParams: widget.accountId == null,
                  ),
                ),
              ),
            Expanded(
              child: masterAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text("Error: $err")),
                data: (masterState) {
                  if (masterState.transactions.isEmpty && !masterState.isLoadingMore) {
                    return const Center(child: Text("No transactions found"));
                  }

                  return Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(transactionsProvider(filter));
                        },
                        child: widget.separateByDate
                            ? _buildGroupedList(masterState.transactions, theme)
                            : _buildSingleList(masterState.transactions),
                      ),
                      // Non-disruptive footer loader pinned at bottom overlay
                      if (masterState.isLoadingMore)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 12,
                          child: Center(
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(20),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text("Loading transactions...", style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the grouped list using Slivers to maintain grouped card styling while fixing the scrollbar
  Widget _buildGroupedList(List<dynamic> transactions, ThemeData theme) {
    final grouped = transactions.groupListsBy((t) => DateTime(t.posted.year, t.posted.month, t.posted.day));

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        for (final entry in grouped.entries)
          SliverMainAxisGroup(
            slivers: [
              // Date Header Sliver
              SliverToBoxAdapter(
                child: SproutRouteWrapper(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4, top: 12),
                    child: Text(entry.key.toShortMonth, style: theme.textTheme.titleSmall),
                  ),
                ),
              ),
              // Day Group Card Sliver
              SliverToBoxAdapter(
                child: SproutRouteWrapper(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SproutCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < entry.value.length; i++) ...[
                          TransactionRow(entry.value[i]),
                          if (i < entry.value.length - 1) const Divider(height: 1),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Builds a single list of transactions if we don't wish to separate by date
  Widget _buildSingleList(List<dynamic> transactions) {
    return SproutCard(
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) => TransactionRow(transactions[index]),
      ),
    );
  }
}
