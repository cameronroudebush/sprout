import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/transaction/models/transaction.dart'; // Make sure to import your Transaction model
import 'package:sprout/transaction/provider.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  int _currentPage = 0;

  void _fetchDataForPage(int page) {
    // Access the provider without listening to rebuild the whole widget on data change
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final rowsPerPage = provider.rowsPerPage;
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
          margin: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: double.infinity,
                child: PaginatedDataTable(
                  header: TextWidget(
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
                  // The source is where the magic happens
                  source: _TransactionDataSource(
                    transactions: provider.transactions,
                    totalRows: provider.totalTransactionCount,
                  ),
                  rowsPerPage: provider.rowsPerPage,
                  onPageChanged: (int pageIndex) {
                    // The page index from the widget is byte-based, so we calculate page number
                    final newPage = pageIndex ~/ provider.rowsPerPage;
                    if (newPage != _currentPage) {
                      setState(() {
                        _currentPage = newPage;
                      });
                      _fetchDataForPage(newPage);
                    }
                  },
                  // Show a loading indicator when fetching data
                  // showProgress: provider.isLoading,
                  // Make table horizontally scrollable on small screens
                  horizontalMargin: 20,
                  columnSpacing: constraints.maxWidth * 0.1, // Responsive column spacing
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
/// This class handles how to build rows from your transaction data.
class _TransactionDataSource extends DataTableSource {
  final List<Transaction> transactions;
  final int totalRows;

  _TransactionDataSource({required this.transactions, required this.totalRows});

  @override
  DataRow? getRow(int index) {
    if (index >= transactions.length) {
      return null; // This can happen if the last page has fewer items than rowsPerPage
    }
    final transaction = transactions[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(transaction.posted.toLocal().toString())),
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
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => totalRows;

  @override
  int get selectedRowCount => 0;
}
