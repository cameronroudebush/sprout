import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';

/// Renders a scrollable list of all user accounts grouped by their [AccountTypeEnum].
///
/// This view provides a high-level overview of balances and institution names,
/// allowing users to quickly scan their total financial distribution.
class AccountSummaryView extends ConsumerWidget {
  final List<Account> accounts;
  final bool isPrivate;

  // TODO: This sucks, improve it

  const AccountSummaryView({super.key, required this.accounts, required this.isPrivate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: AccountTypeEnum.values.map((type) {
        final filtered = accounts.where((a) => a.type == type).toList();
        if (filtered.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupHeader(theme, type.value),
            SproutCard(
              child: Column(
                children: filtered.asMap().entries.map((entry) {
                  return _buildAccountRow(context, entry.value, entry.key == filtered.length - 1);
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  /// Builds the uppercase section header for a specific account group.
  Widget _buildGroupHeader(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(label.toUpperCase(), style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  /// Builds a clickable row for an individual account that navigates to the detail view.
  Widget _buildAccountRow(BuildContext context, Account a, bool isLast) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => NavigationProvider.redirect('accounts', queryParameters: {'id': a.id}),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text(a.institution.name, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
            Text(
              a.balance.toCurrency(isPrivate),
              style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.chevron_right, size: 16),
          ],
        ),
      ),
    );
  }
}
