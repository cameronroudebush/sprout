import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/transaction/models/transaction.dart';
import 'package:sprout/transaction/provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';

/// A card that displays the recent transactions located in the database
class TransactionsCard extends StatefulWidget {
  /// How many rows to render per page
  final int rowsPerPage;

  /// If this should be rendered within it's own card
  final bool applyCard;

  /// If the paginator should render
  final bool allowPagination;

  final bool allowSearch;

  final String? title;

  final bool enforceMinHeight;

  /// The specific account that we want transactions for
  final Account? account;

  const TransactionsCard({
    super.key,
    this.rowsPerPage = 5,
    this.applyCard = true,
    this.allowPagination = true,
    this.allowSearch = true,
    this.title,
    this.account,
    this.enforceMinHeight = true,
  });

  @override
  State<TransactionsCard> createState() => _TransactionsCardState();
}

class _TransactionsCardState extends State<TransactionsCard> {
  int _currentPage = 0;
  String _searchQuery = '';
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDataForPage(_currentPage);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Requests data from the API for the current page
  void _fetchDataForPage(int page) {
    // Do not fetch if we're in a search as the content is already resolved
    if (_searchQuery.isNotEmpty) return;
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.populateTransactions(
      page * widget.rowsPerPage,
      (page + 1) * widget.rowsPerPage,
      shouldNotify: true,
      account: widget.account,
    );
  }

  void _goToPage(int pageIndex) {
    setState(() {
      _currentPage = pageIndex;
    });
    _fetchDataForPage(_currentPage);
  }

  /// Goes to the previous page
  void _goToPreviousPage() {
    final page = (_currentPage - 1).clamp(0, _currentPage);
    _goToPage(page);
  }

  /// Goes to the next page
  void _goToNextPage(int totalPages) {
    final page = (_currentPage + 1).clamp(0, totalPages - 1);
    _goToPage(page);
  }

  /// Returns the providers transactions
  List<Transaction> _getTransactionsList() {
    final transactionProvider = ServiceLocator.get<TransactionProvider>();
    final transactions = widget.account != null
        ? transactionProvider.transactions.where((t) => t.account.id == widget.account!.id).toList()
        : transactionProvider.transactions;
    if (_searchQuery.isEmpty) {
      return transactions;
    } else {
      return transactions.where((transaction) {
        final containsDescription = transaction.description.toLowerCase().contains(_searchQuery.toLowerCase());
        if (widget.account != null) {
          return containsDescription && transaction.account.id == widget.account!.id;
        } else {
          return containsDescription;
        }
      }).toList();
    }
  }

  int _getTotalTransactionCount(TransactionProvider provider) {
    if (_searchQuery.isNotEmpty) {
      final transactionsForQuery = _getTransactionsList();
      return transactionsForQuery.length;
    } else if (widget.account != null && provider.totalTransactions != null) {
      return provider.totalTransactions!.accounts[widget.account!.id] ?? 0;
    } else {
      return provider.totalTransactions?.total ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final totalTransactionCount = _getTotalTransactionCount(provider);
        final totalPages = (totalTransactionCount / widget.rowsPerPage).ceil();
        final transactions = _getTransactions();
        final transactionsWidgets = transactions.map((e) => e[0] as List<Widget>).expand((e) => e).toList();
        final searchIsActive = _debounce?.isActive ?? false;
        final minHeight = (widget.rowsPerPage * TransactionRow.rowHeight) + 5;

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            if (widget.title != null)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.directional(start: 12, top: 4, bottom: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          referenceSize: 1.5,
                          text: widget.title!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ),
            // Search Bar
            if (widget.allowSearch)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: 'Search by description',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _currentPage = 0;
                      });
                      if (searchIsActive) _debounce?.cancel();
                      if (value.isNotEmpty) {
                        _debounce = Timer(const Duration(milliseconds: 500), () {
                          provider.populateTransactionsWithSearch(value, shouldNotify: true, account: widget.account);
                        });
                      }
                    },
                  ),
                ),
              ),
            const Divider(height: 1),
            // Spinner if we're waiting for a search result
            if (searchIsActive || provider.isLoading)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(height: 325, child: Center(child: CircularProgressIndicator())),
              ),
            // Render rows
            if (!searchIsActive && !provider.isLoading)
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: widget.enforceMinHeight ? minHeight : 0),
                child: Column(
                  mainAxisAlignment: transactionsWidgets.isEmpty ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    // Render any transactions
                    ...transactionsWidgets,
                    // Display if we have no transactions
                    if (transactions.isEmpty && !(searchIsActive || provider.isLoading)) ...[
                      Center(
                        child: Padding(
                          padding: EdgeInsetsGeometry.all(24),
                          child: TextWidget(
                            referenceSize: 1.5,
                            text: "No matching transactions",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const Divider(height: 1),
            // Pagination Controls
            if (widget.allowPagination && totalTransactionCount > widget.rowsPerPage)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SproutTooltip(
                      message: "First page",
                      child: IconButton(
                        padding: const EdgeInsets.all(0),
                        icon: const Icon(Icons.first_page, size: 30),
                        onPressed: _currentPage != 0 ? () => _goToPage(0) : null,
                      ),
                    ),
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: _currentPage > 0 ? () => _goToPreviousPage() : null,
                    ),
                    Text('${_currentPage + 1} / $totalPages'),
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: _currentPage < totalPages - 1 ? () => _goToNextPage(totalPages) : null,
                    ),
                  ],
                ),
              ),
          ],
        );

        return widget.applyCard ? SproutCard(child: content) : content;
      },
    );
  }

  /// Returns the current transactions to render based on the current page
  List<dynamic> _getTransactions() {
    final transactions = _getTransactionsList();
    final transactionsToReturn = [];

    final itemsToRender = transactions.length < widget.rowsPerPage
        ? transactions.length - (_currentPage * widget.rowsPerPage)
        : widget.rowsPerPage;
    // Render the elements
    for (int i = 0; i < itemsToRender; i++) {
      final elementIndex = (_currentPage * widget.rowsPerPage) + i;
      if (elementIndex >= transactions.length) break;
      final transaction = transactions.isNotEmpty ? transactions.elementAt(elementIndex) : null;
      final widgets = <Widget>[TransactionRow(transaction: transaction, isEvenRow: elementIndex % 2 == 0)];
      if (i < itemsToRender - 1) {
        widgets.add(const Divider(height: 1));
      }
      transactionsToReturn.add([widgets, transaction!]);
    }
    return transactionsToReturn;
  }
}
