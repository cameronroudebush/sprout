import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/speed_dial.dart';
import 'package:sprout/transaction/transaction_rule_provider.dart';
import 'package:sprout/transaction/widgets/transaction_rule_edit.dart';
import 'package:sprout/transaction/widgets/transaction_rule_row.dart';

/// This widget provides the transaction rules and allows for customization across Sprout
class TransactionRulesPage extends ConsumerWidget {
  const TransactionRulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(transactionRulesProvider);
    final theme = Theme.of(context);

    // Handle the "Organizing transactions..." overlay/loading state
    if (rulesAsync.value?.isRunning == true) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Organizing transactions...", style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return Scaffold(
      floatingActionButton: SproutSpeedDial(
        actions: [
          FABAction(
            icon: Icons.add,
            label: 'Add New Rule',
            onTap: (context) => showSproutPopup(context: context, builder: (_) => const TransactionRuleEdit(null)),
          ),
          FABAction(
            icon: Icons.refresh,
            label: 'Re-run all rules',
            onTap: (context) => ref.read(transactionRulesProvider.notifier).openManualRefreshDialog(context),
          ),
        ],
      ),
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (prov) {
          if (prov.rules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rule_folder_outlined, size: 64, color: theme.dividerColor),
                  const SizedBox(height: 16),
                  const Text("No rules found. Add one to start organizing!", style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 84),
            child: Column(
              spacing: 12,
              children: [
                /// Explanation Card
                SproutCard(
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Transactions are categorized based on the rules below in descending order.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),

                /// Rules List Card
                SproutCard(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: prov.rules.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return TransactionRuleRow(prov.rules[index], index: index);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
