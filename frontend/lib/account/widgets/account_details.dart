import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/models/account_tab_item.dart';
import 'package:sprout/account/models/extensions/account_extensions.dart';
import 'package:sprout/account/widgets/account_logo.dart';
import 'package:sprout/account/widgets/account_sub_selector.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/net-worth/widgets/net_worth_card.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/provider/provider_provider.dart';
import 'package:sprout/routes/transactions.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/extensions/string_extensions.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/notification.dart';
import 'package:sprout/theme/helpers.dart';
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
      _showReSyncPopup();
    }
  }

  /// Renders the popup to ask the user if they want to sync
  void _showReSyncPopup() {
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

  /// Launches the necessary content to fix an institution that has an error
  Future<void> _fixInstitution() async {
    final provider = widget.account.provider;

    if (provider == ProviderTypeEnum.plaid) {
      try {
        final api = await ref.read(providerApiProvider.future);
        final response = await api.plaidProviderControllerCreateLinkToken(
          institutionId: widget.account.institution.id,
        );

        if (response?.linkToken != null) {
          // Open Plaid SDK in update mode
          LinkTokenConfiguration configuration = LinkTokenConfiguration(
            token: response!.linkToken,
          );
          await PlaidLink.create(configuration: configuration);
          PlaidLink.onSuccess.first.then((_) {
            _showReSyncPopup();
          });
          PlaidLink.open();
        }
      } catch (e) {
        ref.read(notificationsProvider.notifier).parseOpenAPIException((e));
      }
    } else if (provider == ProviderTypeEnum.simpleFin) {
      // Handle SimpleFin which is just a simple URL
      final Uri url = Uri.parse('https://beta-bridge.simplefin.org/my-account');
      _expectingReturnFromFix = true;
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        _expectingReturnFromFix = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<AccountTabItem> tabs = [
      AccountTabItem(label: "Overview", icon: Icons.settings, child: _buildOverviewSection(theme)),
      AccountTabItem(label: "Activity", icon: Icons.receipt_long, child: _buildTransactionSection(context, ref)),
    ];

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      final navWidget = Padding(
        padding: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: isDesktop ? 12 : 0),
        child: _buildNav(tabs, theme),
      );

      return Scaffold(
        body: Padding(
          padding: EdgeInsetsGeometry.only(top: 4),
          child: Column(
            children: [
              if (isDesktop) navWidget,
              Expanded(
                child: IndexedStack(index: _selectedIndex, children: tabs.map((tab) => tab.child).toList()),
              ),
              if (!isDesktop) SafeArea(top: false, child: navWidget),
            ],
          ),
        ),
      );
    });
  }

  /// Helper to build the SegmentedButton for navigation on this page
  Widget _buildNav(List<AccountTabItem> tabs, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<int>(
        showSelectedIcon: false,
        segments: tabs.asMap().entries.map((entry) {
          return ButtonSegment(
            value: entry.key,
            label: Text(entry.value.label),
            icon: Icon(entry.value.icon, size: 18),
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
    );
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
                Expanded(
                  child: Row(
                    spacing: 8,
                    children: [
                      AccountLogo(widget.account, height: 36, width: 36),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.account.institution.name,
                              style: theme.textTheme.labelMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.account.name,
                              style: theme.textTheme.labelLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
                invert: widget.account.isDebt),
          ),
        ],
      ),
    );
  }

  /// Builds the account overview information
  Widget _buildOverviewSection(ThemeData theme) {
    final account = widget.account;
    final accountProvider = ref.read(accountsProvider.notifier);
    final zillowAsset =
        account.provider == ProviderTypeEnum.zillow ? ref.watch(zillowInfoProvider(account.id)).value : null;

    final allHistory = ref.watch(historicalAccountDataProvider);
    final timeline = ref.watch(accountTimelineProvider(widget.account.id));
    final accountHistory = allHistory.whenData((list) => list?.firstWhere((h) => h.connectedId == widget.account.id));
    return Column(
      children: [
        // Notifications
        _buildNotifications(theme),
        // Top card
        _buildBalanceHeroCard(theme, accountHistory, timeline),

        // Configuration
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            children: [
              SproutCard(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    spacing: 8,
                    children: [
                      // Account sub type selector
                      Row(
                        spacing: 4,
                        children: [
                          Expanded(
                            child: Text(
                              "Account Sub-Type",
                              style: theme.textTheme.titleSmall,
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
                                style: theme.textTheme.titleSmall,
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
                      _buildStaticRow(theme, Icons.account_balance, "Provider", account.provider.toString()),

                      const Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          if (account.provider == ProviderTypeEnum.zillow && zillowAsset != null)
                            Expanded(
                              child: FilledButton(
                                onPressed: () async {
                                  final Uri url = Uri.parse('https://www.zillow.com/homes/${zillowAsset.zpid}_zpid/');
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                },
                                style: ThemeHelpers.primaryButton,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 8,
                                  children: [Icon(Icons.house), Text("View on Zillow")],
                                ),
                              ),
                            ),

                          // Delete
                          Expanded(
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
                                      await NavigationProvider.redirect("/accounts");
                                    },
                                    child: Text(
                                      "Removing ${account.name} will remove all transactions and history linked to this account. This cannot be undone!",
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
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds notifications to display for the account content
  Widget _buildNotifications(ThemeData theme) {
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
            onClick: _fixInstitution,
          ),
          allowMultiLine: true,
        ),
      );
    }
    return Column(spacing: 0, children: notifications);
  }

  /// Builds the transactions to display related to this account
  Widget _buildTransactionSection(BuildContext context, WidgetRef ref) {
    return TransactionsPage(accountId: widget.account.id, padding: EdgeInsetsGeometry.zero);
  }

  /// Helper for configuration fields that are read only
  Widget _buildStaticRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: theme.textTheme.bodyMedium),
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
        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSecondary),
      ),
    );
  }
}
