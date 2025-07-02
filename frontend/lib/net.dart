import 'package:flutter/material.dart';
import 'package:sprout/utils/formatters.dart';

class NetWorthCard extends StatelessWidget {
  const NetWorthCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy net worth data
    const double currentNetWorth = 12534535435.67;

    return Center(
      child: FractionallySizedBox(
        widthFactor: .7,
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Current Net Worth',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8.0),
                Text(
                  currencyFormatter.format(currentNetWorth),
                  style: const TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  softWrap: false,
                ),
                const SizedBox(height: 16.0),
                // Optional: Add a small trend indicator or message
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.arrow_upward,
                      color: Colors.green[700],
                      size: 18,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '+1.2% since last month',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
