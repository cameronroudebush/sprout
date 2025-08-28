import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
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

  const TransactionsCard({
    super.key,
    this.rowsPerPage = 5,
    this.applyCard = true,
    this.allowPagination = true,
    this.allowSearch = true,
    this.title,
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
    provider.populateTransactions(page * widget.rowsPerPage, (page + 1) * widget.rowsPerPage, shouldNotify: true);
  }

  /// Goes to the previous page
  void _goToPreviousPage() {
    setState(() {
      _currentPage = (_currentPage - 1).clamp(0, _currentPage);
    });
    _fetchDataForPage(_currentPage);
  }

  /// Goes to the next page
  void _goToNextPage(int totalPages) {
    setState(() {
      _currentPage = (_currentPage + 1).clamp(0, totalPages - 1);
    });
    _fetchDataForPage(_currentPage);
  }

  /// Returns the providers transactions
  List<Transaction> _getTransactionsList() {
    final transactionProvider = ServiceLocator.get<TransactionProvider>();
    final transactions = transactionProvider.transactions;
    if (_searchQuery.isEmpty) {
      return transactions;
    } else {
      return transactions.where((transaction) {
        return transaction.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final totalPages = (provider.totalTransactionCount / widget.rowsPerPage).ceil();
        final transactions = _getTransactionsList();
        final searchIsActive = _debounce?.isActive ?? false;

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
                          provider.populateTransactionsWithSearch(value, shouldNotify: true);
                        });
                      }
                    },
                  ),
                ),
              ),
            // Spinner if we're waiting for a search result
            if (searchIsActive || provider.isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(height: 325, child: Center(child: CircularProgressIndicator())),
              ),
            // Render rows
            if (!searchIsActive && !provider.isLoading) Column(children: _getTransactions()),
            // Display if we have no transactions
            if (transactions.isEmpty && !(searchIsActive || provider.isLoading))
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
            // Pagination Controls
            if (widget.allowPagination && provider.totalTransactionCount > widget.rowsPerPage)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPage > 0 ? () => _goToPreviousPage() : null,
                    ),
                    Text('${_currentPage + 1} / $totalPages'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
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
  List<Widget> _getTransactions() {
    final transactions = _getTransactionsList();
    final widgets = <Widget>[];

    final itemsToRender = transactions.length < widget.rowsPerPage
        ? transactions.length - (_currentPage * widget.rowsPerPage)
        : widget.rowsPerPage;
    // Render the elements
    for (int i = 0; i < itemsToRender; i++) {
      final elementIndex = (_currentPage * widget.rowsPerPage) + i;
      if (elementIndex >= transactions.length) break;
      final transaction = transactions.isNotEmpty ? transactions.elementAt(elementIndex) : null;
      widgets.add(TransactionRow(transaction: transaction, isEvenRow: elementIndex % 2 == 0));
      if (i < itemsToRender - 1) {
        widgets.add(const Divider(height: 1));
      }
    }
    return widgets;
  }
}
