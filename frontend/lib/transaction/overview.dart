import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/provider.dart';
import 'package:sprout/category/widgets/dropdown.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/transaction/provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';

/// An overview component that allows the user to navigate their total transactions
class TransactionsOverview extends StatefulWidget {
  /// An account that we should only show transactions for. Used in the query for loading transactions.
  final Account? account;
  final bool allowFiltering;

  /// If we should render the header with information about todays transactions
  final bool renderHeader;

  /// A date we only want to focus on. Does not display any transactions that don't match this date.
  final DateTime? focusDate;

  /// How many transactions we should focus on getting. We won't display over this number if set.
  final int? focusCount;

  /// A category to start filtering on
  final dynamic initialCategoryFilter;

  /// If scrolling down the widget should automatically load more where applicable
  final bool allowLoadingMore;

  /// If the back to top button should render when scrolling
  final bool showBackToTop;

  /// If we should group each transaction by date versus one long list. True is by date.
  final bool separateByDate;

  const TransactionsOverview({
    super.key,
    this.account,
    this.allowFiltering = true,
    this.focusDate,
    this.renderHeader = true,
    this.initialCategoryFilter,
    this.focusCount,
    this.allowLoadingMore = true,
    this.showBackToTop = true,
    this.separateByDate = true,
  });

  @override
  State<TransactionsOverview> createState() => _TransactionsOverviewPageState();
}

class _TransactionsOverviewPageState extends State<TransactionsOverview> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _currentTransactionIndex = TransactionProvider.initialTransactionCount;
  final _transactionsPerPage = TransactionProvider.initialTransactionCount;
  bool _showBackToTop = false;
  double _lastScrollPosition = 0.0;
  StreamSubscription? _onAllDataUpdated;

  /// The category we are currently filtering on
  Category? _filteredCategory = CategoryDropdown.fakeAllCategory;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _onAllDataUpdated = BaseProvider.onAllDataUpdated.listen((_) {
      _currentTransactionIndex = 0;
      _scrollController.jumpTo(0);
      _populateInitialTransactions();
    });
    if (widget.focusCount != null || widget.account != null) _currentTransactionIndex = 0;
    _scrollController.addListener(_onScroll);

    if (widget.initialCategoryFilter == "unknown") {
      _filteredCategory = null;
    } else if (widget.initialCategoryFilter == null) {
      _filteredCategory = CategoryDropdown.fakeAllCategory;
    } else {
      _filteredCategory = widget.initialCategoryFilter;
    }

    _populateInitialTransactions();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _onAllDataUpdated?.cancel();
    super.dispose();
  }

  /// Populates the initial transactions so we have up to the amount possible
  void _populateInitialTransactions() {
    // If we have less than the expected transactional count, forcibly load more
    final provider = ServiceLocator.get<TransactionProvider>();
    final transactionCount = _getFilteredTransactions(provider.transactions).length;
    if (transactionCount < _transactionsPerPage) {
      _loadMoreTransactions();
    }
  }

  void _onScroll() {
    // Show/hide back-to-top button
    if (_scrollController.offset >= 400 && !_showBackToTop) {
      setState(() => _showBackToTop = true);
    } else if (_scrollController.offset < 400 && _showBackToTop) {
      setState(() => _showBackToTop = false);
    }

    final pixels = _scrollController.position.pixels;
    final nearBottom = pixels >= _scrollController.position.maxScrollExtent - 200;
    final scrolledEnough = (pixels - _lastScrollPosition).abs() > 500;

    // If we're near the bottom of the list or have scrolled a significant amount, load more.
    if (widget.allowLoadingMore && (nearBottom || scrolledEnough)) {
      _lastScrollPosition = pixels;
      _loadMoreTransactions();
    }
  }

  /// Scrolls to the top of this view
  void _scrollToTop() {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  /// Fetches the next page of transactions from the provider
  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore) return;
    final provider = ServiceLocator.get<TransactionProvider>();
    final totalTransactions = provider.totalTransactions?.total ?? 0;
    if (_currentTransactionIndex >= totalTransactions) return;
    setState(() => _isLoadingMore = true);

    // Allow the weird way of requesting category data
    dynamic categoryFilter;
    if (_filteredCategory == CategoryDropdown.fakeAllCategory) {
      categoryFilter = null;
    } else if (_filteredCategory == null) {
      categoryFilter = "Unknown";
    } else {
      categoryFilter = _filteredCategory;
    }

    // Request our data
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await provider.populateTransactions(
        startIndex: _currentTransactionIndex,
        endIndex: _currentTransactionIndex + _transactionsPerPage,
        category: categoryFilter,
        description: _searchController.text,
        account: widget.account,
      );
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
      _currentTransactionIndex += _transactionsPerPage;
    });
  }

  /// Returns filtered transactions list based on our filters
  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    List<Transaction> toReturn = transactions;

    if (widget.account != null) {
      toReturn = toReturn.where((t) => t.account.id == widget.account!.id).toList();
    }

    if (widget.focusDate != null) {
      toReturn = toReturn.where((t) => t.posted.isSameDay(widget.focusDate!)).toList();
    }

    if (widget.focusCount != null) {
      if (toReturn.length < widget.focusCount!) {
        toReturn = toReturn.sublist(0, toReturn.length);
      } else {
        toReturn = toReturn.sublist(0, widget.focusCount);
      }
    }

    /// Null is the "Unknown" category selector
    if (_filteredCategory == null) {
      toReturn = toReturn.where((t) => t.category == null).toList();
    } else if (_filteredCategory != null && _filteredCategory != CategoryDropdown.fakeAllCategory) {
      toReturn = toReturn.where((transaction) {
        // Start with the transaction's own category.
        Category? currentCategory = transaction.category;

        // Loop upwards through the parent categories.
        while (currentCategory != null) {
          // If we find a match at any level, include the transaction.
          if (currentCategory.id == _filteredCategory!.id) {
            return true;
          }
          // Move up to the next parent in the hierarchy.
          currentCategory = currentCategory.parentCategory;
        }

        // If no match was found in the hierarchy, exclude the transaction.
        return false;
      }).toList();
    }

    if (_searchController.text.isNotEmpty) {
      toReturn = toReturn.where((transaction) {
        final containsDescription = transaction.description.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        );
        return containsDescription;
      }).toList();
    }

    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer2<TransactionProvider, CategoryProvider>(
      builder: (context, provider, categoryProvider, child) {
        final transactions = _getFilteredTransactions(provider.transactions);
        final isLoading = provider.isLoading || _isLoadingMore;

        return Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppTheme.maxDesktopSize),
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Render the filtering by category
                if (widget.allowFiltering)
                  Padding(
                    padding: EdgeInsetsGeometry.only(top: 4),
                    child: Row(
                      children: [
                        // Description searching
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: 'Search by description',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              suffixIcon: _searchController.value.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        FocusScope.of(context).unfocus();
                                        _searchController.text = "";
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) async {
                              setState(() {
                                _currentTransactionIndex = 0;
                              });
                              await _loadMoreTransactions();
                            },
                          ),
                        ),

                        // Category searching
                        Expanded(
                          child: SproutCard(
                            clip: false,
                            child: CategoryDropdown(_filteredCategory, (c) async {
                              setState(() {
                                _currentTransactionIndex = 0;
                                _filteredCategory = c;
                              });
                              // Make sure to forcible request more so we have the correct amount of data, even considering filtering
                              await _loadMoreTransactions();
                              // Always scroll to the top
                              _scrollToTop();
                            }, displayAllCategoryButton: true),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Render the actual transactions
                Expanded(
                  child: Stack(
                    children: [
                      /// In the event we don't find a match
                      if (transactions.isEmpty && !isLoading)
                        Center(
                          child: TextWidget(
                            text: "No matching transactions",
                            referenceSize: 1.25,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                      if (widget.separateByDate)
                        _buildGroupedByDate(transactions, isLoading, theme)
                      else
                        _buildSingleList(transactions, isLoading),

                      // Back to top button
                      if (widget.showBackToTop && _showBackToTop)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SproutTooltip(
                              message: "Scroll to top",
                              child: FloatingActionButton(onPressed: _scrollToTop, child: Icon(Icons.arrow_upward)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Places all transactions in a single list instead of separating by date
  Widget _buildSingleList(List<Transaction> transactions, bool isLoading) {
    return SproutCard(
      child: ListView.separated(
        controller: _scrollController,
        itemCount: transactions.length + 1,
        separatorBuilder: (context, index) {
          if (index != transactions.length - 1) {
            return const Divider(height: 1);
          } else {
            return const SizedBox.shrink();
          }
        },
        itemBuilder: (context, index) {
          if (index == transactions.length) {
            return isLoading
                ? const Center(
                    child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();
          }
          final transaction = transactions[index];
          return TransactionRow(transaction: transaction, isEvenRow: index % 2 == 0);
        },
      ),
    );
  }

  /// Places all transactions into separate lists by date
  Widget _buildGroupedByDate(List<Transaction> transactions, bool isLoading, ThemeData theme) {
    // Categorize transactions by day.
    final groupedTransactions = transactions.groupListsBy((e) => DateTime(e.posted.year, e.posted.month, e.posted.day));

    return ListView.separated(
      controller: _scrollController,
      itemCount: groupedTransactions.length + 1, // +1 for the loading indicator
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        // If it's the last item, show a loading indicator or an empty box
        if (index == groupedTransactions.length) {
          return isLoading
              ? const Center(
                  child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink();
        }

        final entry = groupedTransactions.entries.elementAt(index);
        final date = entry.key;
        // Sort transactions by pending, then posted date, then description.
        final dailyTransactions = entry.value.sorted((a, b) {
          int compare = (a.pending ? 0 : 1).compareTo(b.pending ? 0 : 1);
          if (compare != 0) return compare;
          compare = b.posted.compareTo(a.posted);
          if (compare != 0) return compare;
          return a.description.compareTo(b.description);
        });
        final totalValueChange = dailyTransactions.fold(0.0, (prev, element) => prev + element.amount);

        return SproutCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display grouping info
              if (widget.renderHeader) ...[
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Date
                      TextWidget(
                        text: date.toShortMonth,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        referenceSize: 1.15,
                      ),

                      /// Total value change
                      TextWidget(
                        text: getFormattedCurrency(totalValueChange),
                        style: TextStyle(color: getBalanceColor(totalValueChange, theme)),
                        referenceSize: 1.15,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],

              // Transactions list
              ...dailyTransactions
                  .mapIndexed((i, t) {
                    final widgets = <Widget>[TransactionRow(transaction: t, isEvenRow: false)];
                    // Add a divider if this isn't the last element
                    if (i != dailyTransactions.length - 1) {
                      widgets.add(const Divider(height: 1));
                    }
                    return widgets;
                  })
                  .expand((e) => e),
            ],
          ),
        );
      },
    );
  }
}
