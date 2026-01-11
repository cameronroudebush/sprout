import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/state_tracker.dart';

/// A widget that takes the currently linked accounts and displays percentages of assets/debts
class AccountPercentageWidget extends StatefulWidget {
  const AccountPercentageWidget({super.key});

  @override
  State<AccountPercentageWidget> createState() => _AccountPercentageWidgetState();
}

class _AccountPercentageWidgetState extends StateTracker<AccountPercentageWidget> {
  @override
  Map<dynamic, DataRequest> get requests => {
    'accounts': DataRequest<AccountProvider, List<Account>>(
      provider: ServiceLocator.get<AccountProvider>(),
      onLoad: (p, force) => p.populateLinkedAccounts(),
      getFromProvider: (p) => p.linkedAccounts,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, provider, child) {
        final accounts = provider.linkedAccounts;

        if (isLoading) return Center(child: CircularProgressIndicator());

        if (accounts.isEmpty) return const SizedBox(height: 100, child: Center(child: Text("No accounts found")));

        // Get assets vs debt accounts
        final assetAccounts = accounts.where((a) {
          return a.type == AccountTypeEnum.depository ||
              a.type == AccountTypeEnum.investment ||
              a.type == AccountTypeEnum.crypto;
        }).toList();

        final debtAccounts = accounts.where((a) {
          return a.type == AccountTypeEnum.credit || a.type == AccountTypeEnum.loan;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            // Assets
            if (assetAccounts.isNotEmpty) _buildProgressSection(context, "Assets", assetAccounts),
            // Debts
            if (debtAccounts.isNotEmpty) _buildProgressSection(context, "Debts", debtAccounts),
          ],
        );
      },
    );
  }

  /// Builds a progress section for the type of account
  Widget _buildProgressSection(BuildContext context, String title, List<Account> accounts) {
    final theme = Theme.of(context);
    // Calculate Total
    final total = accounts.fold(0.0, (sum, acc) => sum + (acc.balance.abs()));

    // Group
    final grouped = groupBy(accounts, (a) => formatAccountType(a.type));

    //  Create List of Maps for display
    final segments = grouped.entries.map((entry) {
      final categoryLabel = entry.key;
      final categoryTotal = entry.value.fold(0.0, (sum, acc) => sum + (acc.balance.abs()));
      final percentage = total == 0 ? 0.0 : (categoryTotal / total);

      return {
        'label': categoryLabel,
        'value': categoryTotal,
        'percentage': percentage,
        'color': _getColorForLabel(categoryLabel),
      };
    }).toList();

    // Get the largest elements first
    segments.sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              getFormattedCurrency(total),
              style: TextStyle(color: getBalanceColor(title == "Debts" ? -total : total, theme), fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 20,
            child: Row(
              children: segments.map((segment) {
                final percentage = segment['percentage'] as double;
                final flex = (percentage * 1000).toInt();

                if (flex <= 0) return const SizedBox();

                return Expanded(
                  flex: flex,
                  child: Tooltip(
                    message: '${segment['label']}: ${getFormattedCurrency(segment['value'] as double)}',
                    child: Container(color: segment['color'] as Color),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: segments.map((segment) {
            final percentage = segment['percentage'] as double;

            return Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: segment['color'] as Color, shape: BoxShape.circle),
                ),
                Text(
                  "${segment['label']} (${(percentage * 100).toStringAsFixed(1)}%)",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // Helper to assign distinct colors based on the label string
  Color _getColorForLabel(String label) {
    final s = label.toLowerCase();

    return switch (s) {
      _ when s == 'cash' => Colors.green,
      _ when s == 'credit' => Colors.redAccent,
      _ when s == 'loan' => Colors.orangeAccent,
      _ when s == 'investment' => Colors.teal,
      _ when s == 'crypto' => Colors.blueAccent,
      _ => Colors.blueGrey,
    };
  }
}
