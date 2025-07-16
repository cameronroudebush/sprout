import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/transaction/models/transaction.dart';
import 'package:sprout/transaction/provider.dart';

class RecentTransactionsCard extends StatefulWidget {
  const RecentTransactionsCard({super.key});

  @override
  State<RecentTransactionsCard> createState() => _RecentTransactionsCardState();
}

class _RecentTransactionsCardState extends State<RecentTransactionsCard> {
  int _currentPage = 0;

  void _fetchDataForPage(int page) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final rowsPerPage = provider.rowsPerPage;
    // Assuming populateTransactions can handle fetching data for a specific page
    provider.populateTransactions(page * rowsPerPage, (page + 1) * rowsPerPage);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: double.infinity,
                child: PaginatedDataTable(
                  header: const TextWidget(
                    referenceSize: 2,
                    text: 'Recent Transactions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Amount'), numeric: true),
                  ],
                  source: _TransactionDataSource(
                    transactions: provider.transactions,
                    totalRows: provider.totalTransactionCount,
                    rowsPerPage: provider.rowsPerPage,
                  ),
                  rowsPerPage: provider.rowsPerPage,
                  onPageChanged: (int pageIndex) {
                    final newPage = pageIndex ~/ provider.rowsPerPage;
                    if (newPage != _currentPage) {
                      setState(() {
                        _currentPage = newPage;
                      });
                      _fetchDataForPage(newPage);
                    }
                  },
                  horizontalMargin: 20,
                  columnSpacing: constraints.maxWidth * 0.05,
                ),
              );
            },
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

  _TransactionDataSource({required this.transactions, required this.totalRows, required this.rowsPerPage});
  @override
  DataRow? getRow(int index) {
    if (index >= transactions.length) {
      return null;
    }
    final transaction = transactions[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(formatDate(transaction.posted))), // Using formatter
        DataCell(Text(transaction.description)),
        DataCell(Text(transaction.category)),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                currencyFormatter.format(transaction.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: transaction.amount >= 0 ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ],
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
