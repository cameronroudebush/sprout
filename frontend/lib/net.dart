import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/account.dart';
import 'package:sprout/api/transaction.dart';
import 'package:sprout/utils/formatters.dart';

class NetWorthWidget extends StatefulWidget {
  const NetWorthWidget({super.key});

  @override
  State<NetWorthWidget> createState() => NetWorthCard();
}

class NetWorthCard extends State<NetWorthWidget> {
  double _netWorth = 0;

  @override
  void initState() {
    super.initState();
    _setNetWorth();

    // Listen for changes in accounts which could effect net worth
    final accountAPI = Provider.of<AccountAPI>(context, listen: false);
    accountAPI.accountsUpdated.on().listen((event) {
      _setNetWorth();
    });
  }

  Future<void> _setNetWorth() async {
    final transactionAPI = Provider.of<TransactionAPI>(context, listen: false);
    double netWorth = await transactionAPI.getNetWorth();
    setState(() {
      _netWorth = netWorth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        // Use ConstrainedBox to set minimum width
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * .4,
        ),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize:
                  MainAxisSize.min, // Use MainAxisSize.min to wrap content
              children: <Widget>[
                Text(
                  'Current Net Worth',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8.0),
                Text(
                  currencyFormatter.format(_netWorth),
                  style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: _netWorth >= 0 ? Colors.green : Colors.red,
                    overflow: TextOverflow
                        .ellipsis, // Consider removing if softWrap is false
                  ),
                  softWrap: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
