import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/models/account_tab_item.dart';
import 'package:sprout/account/widgets/account_logo.dart';
import 'package:sprout/account/widgets/account_sub_selector.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/net-worth/widgets/net_worth_card.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/extensions/string_extensions.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/notification.dart';
import 'package:sprout/theme/helpers.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_row.dart';
import 'package:url_launcher/url_launcher.dart';

/// A responsive view for account details that adapts its navigation
/// based on the user's screen size for better ergonomics.
class AccountDetailsView extends ConsumerStatefulWidget {
  final Account account;
  final bool isPrivate;

  const AccountDetailsView({super.key, required this.account, required this.isPrivate});

  @override
  ConsumerState<AccountDetailsView> createState() => _AccountDetailsViewState();
}

class _AccountDetailsViewState extends ConsumerState<AccountDetailsView> with WidgetsBindingObserver {
  /// Selected tab index for bottom/top navigation
  int _selectedIndex = 0;

  /// Track if we sent the user away to fix their institution connection
  bool _expectingReturnFromFix = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the user returns to the app after clicking the notification
    if (state == AppLifecycleState.resumed && _expectingReturnFromFix) {
      _expectingReturnFromFix = false;
      showSproutPopup(
        context: context,
        builder: (ctx) => SproutBaseDialogWidget(
          'Re-Sync',
          showCloseDialogButton: true,
          showSubmitButton: true,
          submitButtonText: "Sync",
          onSubmitClick: () async {
            Navigator.of(context).pop();
            await ref.read(accountsProvider.notifier).manualSync();
          },
          child: Text(
            'Welcome back! Would you like to re-sync your accounts to get updated data from fixed accounts?',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  /// Launch the external SimpleFin bridge to fix the connection
  Future<void> _launchFixUrl() async {
    final Uri url = Uri.parse('https://beta-bridge.simplefin.org/my-account');
    _expectingReturnFromFix = true;
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _expectingReturnFromFix = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final allHistory = ref.watch(historicalAccountDataProvider);
    final timeline = ref.watch(accountTimelineProvider(widget.account.id));
    final accountHistory = allHistory.whenData((list) => list?.firstWhere((h) => h.connectedId == widget.account.id));

    final List<AccountTabItem> tabs = [
      AccountTabItem(label: "Activity", icon: Icons.receipt_long, child: _buildTransactionSection(context, ref)),
      AccountTabItem(label: "Settings", icon: Icons.settings, child: _buildConfigurationSection(theme)),
    ];

    final List<Widget> notifications = [];

    // Institution Error Notification
    if (widget.account.institution.hasError) {
      notifications.add(
        SproutNotificationWidget(
          SproutNotification(
            "Connection Issue: ${widget.account.institution.name} requires attention.",
            theme.colorScheme.error,
            theme.colorScheme.onError,
            icon: Icons.warning_amber_rounded,
            onClick: _launchFixUrl,
          ),
        ),
      );
    }

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return Scaffold(
        body: Column(
          children: [
            // Notifications
            if (notifications.isNotEmpty) Column(spacing: 0, children: notifications),
            // Top card
            _buildBalanceHeroCard(theme, accountHistory, timeline),

            // Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: tabs.asMap().entries.map((entry) {
                    return ButtonSegment(
                      value: entry.key,
                      label: Text(entry.value.label),
                      icon: Icon(entry.value.icon, size: 18, color: theme.colorScheme.onPrimaryContainer),
                    );
                  }).toList(),
                  selected: {_selectedIndex},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() => _selectedIndex = newSelection.first);
                  },
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    selectedForegroundColor: theme.colorScheme.onPrimary,
                    selectedBackgroundColor: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),

            // Content display for the bottom nav
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: tabs.map((tab) => tab.child).toList()),
            ),
          ],
        ),
      );
    });
  }

  /// Builds the top hero card featuring account identification and the NetWorthCard
  Widget _buildBalanceHeroCard(
    ThemeData theme,
    AsyncValue<EntityHistory?> historyData,
    AsyncValue<List<HistoricalDataPoint>?> timelineData,
  ) {
    return SproutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    AccountLogo(widget.account, height: 36, width: 36),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.account.institution.name, style: theme.textTheme.labelMedium),
                        Text(
                          widget.account.name,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                _getTypeBadge(theme),
              ],
            ),
          ),

          // Renders the net worth card
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: NetWorthDisplay(
              historyData: historyData,
              timelineData: timelineData,
              currentValue: AsyncValue.data(widget.account.balance),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Configuration tab with editable inputs for Sub-Type and Interest Rate.
  Widget _buildConfigurationSection(ThemeData theme) {
    final account = widget.account;
    final accountProvider = ref.read(accountsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        SproutCard(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              spacing: 16,
              children: [
                // Account sub type selector
                Row(
                  spacing: 4,
                  children: [
                    Expanded(
                      child: Text(
                        "Account Sub-Type",
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 240,
                      child: AccountSubTypeSelect(
                        account,
                        onChanged: (newSubType) {
                          account.subType = newSubType;
                          accountProvider.edit(account);
                        },
                      ),
                    ),
                  ],
                ),

                // Interest Rate Input (Only for Liabilities/Loans)
                if (account.type == AccountTypeEnum.loan || account.type == AccountTypeEnum.credit)
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Text(
                          "Interest Rate",
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                          key: Key("${account.id}_rate_${account.interestRate}"),
                          initialValue: account.interestRate?.toString(),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.end, // Aligns value with dropdown text
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.percent, size: 18),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onFieldSubmitted: (value) {
                            final newVal = double.tryParse(value);
                            if (newVal != account.interestRate) {
                              account.interestRate = newVal;
                              accountProvider.edit(account);
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                const Divider(),

                // Static Read-Only Fields
                _buildStaticRow(theme, Icons.account_balance, "Provider", account.provider),
                _buildStaticRow(theme, Icons.language, "Currency", account.currency),
                _buildStaticRow(theme, Icons.fingerprint, "Account ID", account.id, isLast: true),

                const Divider(),

                // Delete
                SizedBox(
                  width: 240,
                  child: FilledButton(
                    onPressed: () {
                      // Confirmation dialog
                      showSproutPopup(
                        context: context,
                        builder: (ctx) => SproutBaseDialogWidget(
                          'Delete Account',
                          showCloseDialogButton: true,
                          closeButtonStyle: ThemeHelpers.primaryButton,
                          showSubmitButton: true,
                          submitButtonText: "Delete",
                          submitButtonStyle: ThemeHelpers.errorButton,
                          onSubmitClick: () async {
                            Navigator.of(context).pop();
                            await accountProvider.delete(account.id);
                          },
                          child: Text(
                            "Are you sure you would like to delete this account? You'll lose all previous history. This action cannot be reversed.",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                    style: ThemeHelpers.errorButton,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8,
                      children: [Icon(Icons.delete), Text("Delete")],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the transactions to display related to this account
  // TODO: Replace with infinite scroll transactions
  Widget _buildTransactionSection(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    return transactionsAsync.when(
      data: (state) {
        final filtered = state.transactions.where((t) => t.account.id == widget.account.id).toList();
        if (filtered.isEmpty) return const Center(child: Text("No transactions recorded."));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) => TransactionRow(transaction: filtered[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text("Error loading transactions")),
    );
  }

  /// Helper for configuration fields that are read only
  Widget _buildStaticRow(ThemeData theme, IconData icon, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Returns a badge that displays what type of account this is
  Widget _getTypeBadge(ThemeData theme) {
    final type = widget.account.type;
    var typeString = type.value;
    if (type == AccountTypeEnum.depository) typeString = "Cash";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: theme.colorScheme.secondary, borderRadius: BorderRadius.circular(8)),
      child: Text(
        typeString.toTitleCase,
        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondary),
      ),
    );
  }
}
