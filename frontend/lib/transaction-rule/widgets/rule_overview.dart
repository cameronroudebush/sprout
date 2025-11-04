import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/auto_update_state.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/page_loading.dart';
import 'package:sprout/transaction-rule/transaction_rule.provider.dart';
import 'package:sprout/transaction-rule/widgets/rule_row.dart';

/// A widget that displays all of our transaction rules and allows adding more
class TransactionRuleOverview extends StatefulWidget {
  const TransactionRuleOverview({super.key});

  @override
  State<TransactionRuleOverview> createState() => _TransactionRuleOverviewState();
}

class _TransactionRuleOverviewState extends AutoUpdateState<TransactionRuleOverview, TransactionRuleProvider> {
    @override 
  TransactionRuleProvider provider = ServiceLocator.get<TransactionRuleProvider>();

  @override
  Future<dynamic> Function(bool showLoaders) loadData =
      ServiceLocator.get<TransactionRuleProvider>().populateTransactionRules;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Consumer<TransactionRuleProvider>(
      builder: (context, provider, child) {
        final isLoading = provider.isLoading || provider.transactionRulesRunning;

        if (isLoading) {
          return PageLoadingWidget(
            loadingText: provider.transactionRulesRunning
                ? "Organizing transactions..."
                : PageLoadingWidget.defaultLoadingText,
          );
        }

        if (provider.rules.isEmpty && !isLoading) {
          return SizedBox(
            height: mediaQuery.height * .75,
            child: Center(
              child: Padding(
                padding: EdgeInsetsGeometry.all(16),
                child: Text(
                  "No rules found. Add one above to start organizing!",
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            /// Explanation
            SproutCard(
              child: Padding(
                padding: EdgeInsetsGeometry.all(12),
                child: Column(
                  children: [
                    Text(
                      "Transactions are categorized based on the below rules in descending order.",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Render each rule
            SproutCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Render all the rules
                  if (!isLoading)
                    ...provider.rules
                        .mapIndexed((i, e) {
                          final widgets = <Widget>[TransactionRuleRow(e, index: i)];
                          // Add a divider if this isn't the last element
                          if (e != provider.rules.last) {
                            widgets.add(const Divider(height: 1));
                          }
                          return widgets;
                        })
                        .expand((e) => e),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
