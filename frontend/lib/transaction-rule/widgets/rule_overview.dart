import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/transaction-rule/transaction_rule.provider.dart';
import 'package:sprout/transaction-rule/widgets/rule_row.dart';

/// A widget that displays all of our transaction rules and allows adding more
class TransactionRuleOverview extends StatefulWidget {
  const TransactionRuleOverview({super.key});

  @override
  State<TransactionRuleOverview> createState() => _TransactionRuleOverviewState();
}

class _TransactionRuleOverviewState extends State<TransactionRuleOverview> {
  @override
  Future<void> initState() async {
    super.initState();
    // Request data
    final transactionRuleProvider = ServiceLocator.get<TransactionRuleProvider>();
    await transactionRuleProvider.populateTransactionRules();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionRuleProvider>(
      builder: (context, provider, child) {
        final isLoading = provider.isLoading || provider.transactionRulesRunning;

        return Column(
          children: [
            /// Explanation
            SproutCard(
              child: Padding(
                padding: EdgeInsetsGeometry.all(12),
                child: Column(
                  children: [
                    TextWidget(
                      referenceSize: 1.25,
                      text: "Transactions are categorized automatically based on the rules below, in descending order.",
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
                  if (provider.rules.isEmpty && !isLoading)
                    Center(
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(16),
                        child: TextWidget(
                          referenceSize: 1.25,
                          text: "No rules found. Add one above to start organizing!",
                        ),
                      ),
                    ),

                  if (isLoading)
                    Padding(
                      padding: EdgeInsetsGeometry.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),

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
