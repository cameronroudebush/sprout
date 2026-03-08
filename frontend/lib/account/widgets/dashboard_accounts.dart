import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_logo.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A widget that provides an overview of all accounts for the dashboard
class DashboardAccountsCard extends ConsumerWidget {
  const DashboardAccountsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final isPrivate = ref.watch(userConfigProvider).value?.privateMode ?? false;

    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: accountsAsync.when(
          data: (state) => _buildBody(context, state.accounts, isPrivate),
          loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  /// Constructs the body of the accounts view by separating the accounts between types for individual row displays
  Widget _buildBody(BuildContext context, List<Account> accounts, bool isPrivate) {
    final theme = Theme.of(context);

    // Group by type
    final depository = accounts.where((a) => a.type == AccountTypeEnum.depository).toList();
    final investments = accounts.where((a) => a.type == AccountTypeEnum.investment).toList();
    final crypto = accounts.where((a) => a.type == AccountTypeEnum.crypto).toList();
    final creditCards = accounts.where((a) => a.type == AccountTypeEnum.credit).toList();
    final loans = accounts.where((a) => a.type == AccountTypeEnum.loan).toList();

    // Calculate totals
    final cashTotal = depository.fold(0.0, (sum, a) => sum + a.balance);
    final investTotal = investments.fold(0.0, (sum, a) => sum + a.balance);
    final cryptoTotal = crypto.fold(0.0, (sum, a) => sum + a.balance);
    final creditTotal = creditCards.fold(0.0, (sum, a) => sum + a.balance.abs());
    final loanTotal = loans.fold(0.0, (sum, a) => sum + a.balance.abs());

    // Calculate overalls
    final totalAssets = cashTotal + investTotal + cryptoTotal;
    final totalDebts = creditTotal + loanTotal;
    final visualTotal = totalAssets + totalDebts;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Summary header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 12,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SummaryLabel(label: "Assets", amount: totalAssets, color: Colors.green, isPrivate: isPrivate),
                  _SummaryLabel(
                    label: "Debts",
                    amount: totalDebts,
                    color: Colors.redAccent,
                    isPrivate: isPrivate,
                    isEnd: true,
                  ),
                ],
              ),
              Container(
                height: 10,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    // Assets
                    _buildBarSegment(cashTotal, visualTotal, Colors.teal),
                    _buildBarSegment(investTotal, visualTotal, Colors.green),
                    _buildBarSegment(cryptoTotal, visualTotal, Colors.blue),
                    // Debts
                    _buildBarSegment(creditTotal, visualTotal, Colors.red),
                    _buildBarSegment(loanTotal, visualTotal, Colors.orangeAccent),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Render each account type separately
        if (depository.isNotEmpty)
          _AccountGroupSection(title: "Cash", accounts: depository, isPrivate: isPrivate, accentColor: Colors.teal),
        if (investments.isNotEmpty)
          _AccountGroupSection(
            title: "Investments",
            accounts: investments,
            isPrivate: isPrivate,
            accentColor: Colors.green,
          ),
        if (crypto.isNotEmpty)
          _AccountGroupSection(title: "Crypto", accounts: crypto, isPrivate: isPrivate, accentColor: Colors.blue),
        if (creditCards.isNotEmpty)
          _AccountGroupSection(
            title: "Credit Cards",
            accounts: creditCards,
            isPrivate: isPrivate,
            accentColor: Colors.red,
            isNegative: true,
          ),
        if (loans.isNotEmpty)
          _AccountGroupSection(
            title: "Loans",
            accounts: loans,
            isPrivate: isPrivate,
            accentColor: Colors.orangeAccent,
            isNegative: true,
          ),
      ],
    );
  }

  /// Builds a segment for the bar based on the total value. Together it builds a nice display of all assets vs debts
  Widget _buildBarSegment(double value, double total, Color color) {
    if (value <= 0 || total <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: (value / total * 1000).toInt().clamp(1, 1000),
      child: Container(color: color),
    );
  }
}

/// A widget that renders an account type group and allows individual rendering of those accounts
class _AccountGroupSection extends StatelessWidget {
  final String title;
  final List<Account> accounts;
  final bool isPrivate;
  final Color accentColor;
  final bool isNegative;

  const _AccountGroupSection({
    required this.title,
    required this.accounts,
    required this.isPrivate,
    required this.accentColor,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = accounts.fold(0.0, (sum, a) => sum + (isNegative ? a.balance.abs() : a.balance));

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        visualDensity: VisualDensity.compact,
        leading: Icon(Icons.stop_rounded, color: accentColor, size: 16),
        title: Text(
          title.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          total.toCurrency(isPrivate),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            color: isNegative ? Colors.redAccent : Colors.green,
          ),
        ),
        children: accounts.map((acc) => _AccountItemRow(acc, isPrivate)).toList(),
      ),
    );
  }
}

/// Renders an individual account in a row with it's info
class _AccountItemRow extends StatelessWidget {
  final Account account;
  final bool isPrivate;

  const _AccountItemRow(this.account, this.isPrivate);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        /// Navigate to a specific account
        NavigationProvider.redirect('/accounts', queryParameters: {'id': account.id});
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 36, right: 36, top: 10, bottom: 10),
        child: Row(
          children: [
            AccountLogo(account),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                account.name,
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              account.balance.toCurrency(isPrivate),
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 14, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

/// A summary label for the type of account. Utilized as Assets vs Debts
class _SummaryLabel extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isPrivate;
  final bool isEnd;

  const _SummaryLabel({
    required this.label,
    required this.amount,
    required this.color,
    required this.isPrivate,
    this.isEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          amount.toCurrency(isPrivate),
          style: theme.textTheme.titleSmall?.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
