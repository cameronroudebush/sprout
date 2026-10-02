import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/speed_dial.dart';
import 'package:sprout/transaction/transaction_rule_provider.dart';
import 'package:sprout/transaction/widgets/transaction_rule_edit.dart';
import 'package:sprout/transaction/widgets/transaction_rule_row.dart';

/// This widget provides the transaction rules and allows for customization across Sprout
class TransactionRulesPage extends ConsumerStatefulWidget {
  const TransactionRulesPage({super.key});

  @override
  ConsumerState<TransactionRulesPage> createState() =>
      _TransactionRulesPageState();
}

class _TransactionRulesPageState extends ConsumerState<TransactionRulesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesRule(
    TransactionRule rule,
    String searchQuery,
    Map<String, String> categoryNames,
    Map<String, String> accountNames,
  ) {
    if (searchQuery.isEmpty) return true;

    final categoryName = rule.categoryId == null
        ? 'Uncategorized'
        : categoryNames[rule.categoryId] ?? '';
    final accountName =
        rule.accountId == null ? '' : accountNames[rule.accountId] ?? '';
    return [
      rule.value,
      rule.type.value,
      categoryName,
      accountName,
      rule.strict ? 'exact' : 'contains',
    ].any((value) => value.toLowerCase().contains(searchQuery));
  }

  @override
  Widget build(BuildContext context) {
    final rulesAsync = ref.watch(transactionRulesProvider);

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
            onTap: (context) => showSproutPopup(
                context: context,
                builder: (_) => const TransactionRuleEdit(null)),
          ),
          FABAction(
            icon: Icons.refresh,
            label: 'Re-run all rules',
            onTap: (context) => ref
                .read(transactionRulesProvider.notifier)
                .openManualRefreshDialog(context),
          ),
        ],
      ),
      body: rulesAsync.whenDefault(
        customErrorMessage: "Failed to load transaction rules",
        data: (prov) {
          final searchQuery = _searchController.text.trim().toLowerCase();
          final categories = ref.watch(categoriesProvider).value ?? [];
          final accounts = ref.watch(accountsProvider).value?.accounts ?? [];
          final categoryNames = {
            for (final category in categories) category.id: category.name,
          };
          final accountNames = {
            for (final account in accounts) account.id: account.name,
          };
          final filteredRules = prov.rules
              .where((rule) => _matchesRule(
                    rule,
                    searchQuery,
                    categoryNames,
                    accountNames,
                  ))
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 84),
            child: SproutRouteWrapper(
              child: Column(
                children: [
                  /// Explanation Card
                  SproutCard(
                    child: const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text("How rules are applied"),
                      subtitle: Text(
                        "Enabled rules run from highest number to lowest. The first match assigns its category. Description rules can match exact text or partial text; use | for alternatives. Re-run all rules to apply them to existing transactions.",
                      ),
                    ),
                  ),

                  /// Rules List Card
                  SproutCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search rules...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: searchQuery.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear search',
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    ),
                              isDense: true,
                              border: const OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.search,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (filteredRules.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: searchQuery.isEmpty
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 12,
                                    children: [
                                      const Text(
                                        'No rules yet. Add one to categorize matching transactions automatically.',
                                        textAlign: TextAlign.center,
                                      ),
                                      FilledButton.icon(
                                        onPressed: () => showSproutPopup(
                                          context: context,
                                          builder: (_) =>
                                              const TransactionRuleEdit(null),
                                        ),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add rule'),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'No rules match your search.',
                                    textAlign: TextAlign.center,
                                  ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredRules.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              return TransactionRuleRow(filteredRules[index],
                                  index: index);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
