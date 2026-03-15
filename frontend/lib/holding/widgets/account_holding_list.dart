import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/holding/widgets/holding_row.dart';
import 'package:sprout/shared/widgets/card.dart';

/// This widget is used to display account holdings in relation to a specific account
class AccountHoldingsList extends ConsumerWidget {
  final String accountId;
  final String? selectedId;
  final Function(Holding holding) onSelect;

  const AccountHoldingsList({super.key, required this.accountId, this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsAsync = ref.watch(accountHoldingsProvider(accountId));
    return holdingsAsync.when(
      loading: () => const Center(
        child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()),
      ),
      error: (err, _) => Center(child: Text("Error loading holdings: $err")),
      data: (holdings) {
        if (holdings.isEmpty) return const SizedBox.shrink();

        return SproutCard(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: holdings.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final holding = holdings[index];
              final isSelected = selectedId == holding.id;

              return HoldingRow(holding: holding, isSelected: isSelected, onSelect: () => onSelect(holding));
            },
          ),
        );
      },
    );
  }
}
