import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/transaction/models/transaction_rule.dart';
import 'package:sprout/transaction/provider.dart';
import 'package:sprout/transaction/widgets/rule_info.dart';
import 'package:sprout/transaction/widgets/rule_row.dart';

/// A widget that displays all of our transaction rules and allows adding more
class TransactionRuleOverview extends StatelessWidget {
  const TransactionRuleOverview({super.key});

  Future<void> _openTransactionRuleInfo(BuildContext context, TransactionRule? rule) async {
    await showDialog(context: context, builder: (_) => TransactionRuleInfo(rule));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
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
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: "Rules",
                          referenceSize: 1.25,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Add button
                        SproutTooltip(
                          message: "Add a new transaction rule",
                          child: IconButton(
                            onPressed: () => _openTransactionRuleInfo(context, null),
                            icon: Icon(Icons.add),
                            style: AppTheme.primaryButton,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
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
