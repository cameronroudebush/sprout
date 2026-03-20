import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/shared/models/extensions/date_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/transaction/models/transaction_state.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';

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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
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

      _fetchPage(reset: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Fetches the content that needs based on our current filter
  Future<void> _fetchPage({bool reset = false}) async {
    final filters = ref.read(transactionFilterStateProvider);

    await ref.read(transactionsProvider.notifier).fetchFilteredPage(
          startIndex: reset ? 0 : _filteredOffset,
          resetList: reset,
          accountId: filters.accountId,
          catId: filters.categoryId,
          search: filters.search,
        );
  }

  /// What to do when the category dropdown changes
  void _onFilterChanged(String? newCatId) {
    final notifier = ref.read(transactionFilterStateProvider.notifier);
    notifier.update(ref.read(transactionFilterStateProvider).copyWith(categoryId: newCatId));

    _fetchPage(reset: true);
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

  /// What to do when the search term string changes
  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final notifier = ref.read(transactionFilterStateProvider.notifier);
      notifier.update(ref.read(transactionFilterStateProvider).copyWith(search: val));

      _fetchPage(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final masterAsync = ref.watch(transactionsProvider);

    final filteredTransactions = ref.watch(filteredTransactionsProvider);

    return Padding(
      padding: widget.padding,
      child: Column(
        children: [
          if (widget.allowFiltering) _buildFilters(theme),
          Expanded(
            child: masterAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
              data: (masterState) {
                if (filteredTransactions.isEmpty && !masterState.isLoadingMore) {
                  return const Center(child: Text("No matching transactions found."));
                }

                return RefreshIndicator(
                  color: theme.colorScheme.onSecondaryContainer,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  onRefresh: () async {
                    await _fetchPage(reset: true);
                  },
                  child: widget.separateByDate
                      ? _buildGroupedList(filteredTransactions, masterState.isLoadingMore, theme)
                      : _buildSingleList(filteredTransactions, masterState.isLoadingMore),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the filters for the top row to decide what to render
  Widget _buildFilters(ThemeData theme) {
    final categories = ref.watch(categoriesProvider).value ?? [];
    final currentFilters = ref.watch(transactionFilterStateProvider);
    final selectedId = currentFilters.categoryId;

    return Padding(
      padding: widget.padding,
      child: SproutLayoutBuilder((isDesktop, context, constraints) {
        final searchField = TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search description...',
            prefixIcon: Icon(Icons.search),
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onChanged: _onSearchChanged,
        );

        Category initialCategory;
        if (selectedId == CategoryDropdown.fakeAllCategory.id) {
          initialCategory = CategoryDropdown.fakeAllCategory;
        } else if (selectedId == CategoryDropdown.unknownCategory.id) {
          initialCategory = CategoryDropdown.unknownCategory;
        } else {
          initialCategory = categories.firstWhereOrNull((c) => c.id == selectedId) ?? CategoryDropdown.fakeAllCategory;
        }

        final categoryField = CategoryDropdown(
          initialCategory,
          (cat) => _onFilterChanged(cat?.id),
          displayAllCategoryButton: true,
        );

        if (isDesktop) {
          return Row(
            spacing: 12,
            children: [
              Expanded(child: searchField),
              Expanded(child: categoryField),
            ],
          );
        }

        return Column(spacing: 8, children: [searchField, categoryField]);
      }),
    );
  }

  /// Builds the grouped lists based on the date of a transaction
  Widget _buildGroupedList(List<dynamic> transactions, bool isLoadingMore, ThemeData theme) {
    final grouped = transactions.groupListsBy((t) => DateTime(t.posted.year, t.posted.month, t.posted.day));

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      // Add one to index for the bottom loader
      itemCount: grouped.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == grouped.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final date = grouped.keys.elementAt(index);
        final dayTransactions = grouped.values.elementAt(index);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(date.toShortMonth, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 8),
          ],
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
