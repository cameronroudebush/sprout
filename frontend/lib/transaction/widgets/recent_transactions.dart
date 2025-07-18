import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/transaction/models/transaction.dart';
import 'package:sprout/transaction/provider.dart';

class RecentTransactionsCard extends StatefulWidget {
  const RecentTransactionsCard({super.key});

  @override
  State<RecentTransactionsCard> createState() => _RecentTransactionsCardState();
}

class _RecentTransactionsCardState extends State<RecentTransactionsCard> {
  int _currentPage = 0;
  int _rowsPerPage = 5;

  void _fetchDataForPage(int page) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.populateTransactions(page * _rowsPerPage, (page + 1) * _rowsPerPage, shouldNotify: true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        double pageHeight = MediaQuery.of(context).size.height;
        double tableRowHeight = pageHeight < 1000 ? 150 : 110;
        _rowsPerPage = (pageHeight / tableRowHeight).round();
        return ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: constraints.maxWidth,
                child: PaginatedDataTable(
                  columns: const [
                    DataColumn(
                      label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    DataColumn(
                      label: Text(' ', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    DataColumn(
                      label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    DataColumn(
                      label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                      numeric: true,
                    ),
                  ],
                  source: _TransactionDataSource(
                    transactions: provider.transactions,
                    totalRows: provider.totalTransactionCount,
                    rowsPerPage: _rowsPerPage,
                    context: context,
                  ),
                  rowsPerPage: _rowsPerPage,
                  onPageChanged: (int pageIndex) {
                    final newPage = pageIndex ~/ _rowsPerPage;
                    if (newPage != _currentPage) {
                      setState(() {
                        _currentPage = newPage;
                      });
                      _fetchDataForPage(newPage);
                    }
                  },
                  horizontalMargin: 20,
                  columnSpacing: constraints.maxWidth * 0.03,
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 60,
                  headingRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                    return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08);
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A custom data source for the PaginatedDataTable.
class _TransactionDataSource extends DataTableSource {
  final List<Transaction> transactions;
  final int totalRows;
  final int rowsPerPage;
  final BuildContext context;

  _TransactionDataSource({
    required this.transactions,
    required this.totalRows,
    required this.rowsPerPage,
    required this.context,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= transactions.length) {
      return null;
    }
    final transaction = transactions[index];

    final isEvenRow = index % 2 == 0;
    final rowColor = WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);
      }
      if (transaction.pending) {
        return Colors.grey.shade50.withValues(alpha: 0.1);
      }
      // Alternating row color
      return isEvenRow ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2) : null;
    });

    final screenWidth = MediaQuery.of(context).size.width;
    return DataRow.byIndex(
      index: index,
      color: rowColor,
      cells: [
        // Date
        DataCell(Text(formatDate(transaction.posted))),
        // Pending
        DataCell(
          transaction.pending
              ? Tooltip(
                  message: 'Transaction is pending',
                  child: Icon(Icons.pending, color: Theme.of(context).colorScheme.secondary),
                )
              : const SizedBox.shrink(),
        ),
        // Description
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth < 450 ? screenWidth * .3 : screenWidth * .5),
            child: Text(
              transaction.description,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // Amount
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              currencyFormatter.format(transaction.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.amount >= 0 ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => transactions.length < totalRows;

  @override
  int get rowCount => totalRows;

  @override
  int get selectedRowCount => 0;
}
