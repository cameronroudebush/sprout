import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/shared/models/extensions/date_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';

/// A page that allows displaying all transactions, or ones given by a specific account
class TransactionsPage extends ConsumerStatefulWidget {
  /// Allows filtering transactions to a specific account
  final String? accountId;
  final bool allowFiltering;
  final bool separateByDate;

  const TransactionsPage({super.key, this.accountId, this.allowFiltering = true, this.separateByDate = true});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  int _filteredOffset = 0;

  // Track local UI state for filtering
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _selectedCategoryId = CategoryDropdown.fakeAllCategory.id;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Fetches the content that needs based on our current filter
  Future<void> _fetchPage({bool reset = false}) async {
    if (reset) {
      setState(() => _filteredOffset = 0);
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    }

    await ref
        .read(transactionsProvider.notifier)
        .fetchFilteredPage(
          startIndex: _filteredOffset,
          accountId: widget.accountId,
          catId: _selectedCategoryId,
          search: _searchController.text,
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

  void _onFilterChanged(String? newCatId) {
    _selectedCategoryId = newCatId;
    _fetchPage(reset: true);
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _fetchPage(reset: true));
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final masterAsync = ref.watch(transactionsProvider);

    final filteredTransactions = ref.watch(
      filteredTransactionsProvider(
        accountId: widget.accountId,
        categoryId: _selectedCategoryId,
        search: _searchController.text,
      ),
    );

    return Column(
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
                onRefresh: () async => ref.invalidate(transactionsProvider),
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

  /// Builds the filters for the top row to decide what to render
  Widget _buildFilters(ThemeData theme) {
    final categories = ref.watch(categoriesProvider).value ?? [];

    return Padding(
      padding: const EdgeInsets.all(8.0),
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

        final initialCategory =
            categories.firstWhereOrNull((c) => c.id == _selectedCategoryId) ?? CategoryDropdown.fakeAllCategory;

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(date.toShortMonth, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ),
            SproutCard(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dayTransactions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, tIndex) => TransactionRow(transaction: dayTransactions[tIndex]),
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
          return TransactionRow(transaction: transactions[index]);
        },
      ),
    );
  }
}
