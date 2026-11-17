import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/models/extensions/account_extensions.dart';
import 'package:sprout/account/widgets/account_icon.dart';
import 'package:sprout/account/widgets/account_net_worth.dart';
import 'package:sprout/account/widgets/account_sub_selector.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/institution/institution_provider.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/provider/provider_provider.dart';
import 'package:sprout/provider/widgets/provider_display.dart';
import 'package:sprout/routes/transactions.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/dialog/edit_dialog.dart';
import 'package:sprout/shared/models/extensions/string_extensions.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/notification.dart';
import 'package:sprout/shared/widgets/tab_selector.dart';

/// A simple record type to hold the combined data for our generic widget
typedef AccountChartData = ({
  EntityHistory? history,
  List<HistoricalDataPoint>? timeline
});

/// This page provides the overall account details view
class AccountDetailsView extends ConsumerStatefulWidget {
  final Account account;
  final VoidCallback onUpdateConnection;

  const AccountDetailsView({
    super.key,
    required this.account,
    required this.onUpdateConnection,
  });

  @override
  ConsumerState<AccountDetailsView> createState() => _AccountDetailsViewState();
}

class _AccountDetailsViewState extends ConsumerState<AccountDetailsView> {
  double get _mobileTabScrollInset =>
      MediaQuery.sizeOf(context).width < SproutLayoutBuilder.desktopBreakpoint
          ? SproutTabbedLayout.mobileNavigationScrollInset
          : 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const tabs = <SproutTabOption<int>>[
      SproutTabOption(value: 0, label: 'Overview'),
      SproutTabOption(value: 1, label: 'Activity'),
    ];
    final tabViews = [
      _buildOverviewSection(theme),
      _buildTransactionSection(context, ref),
    ];
    final selectedIndex =
        NavigationProvider.queryParameter(context, 'tab') == 'activity' ? 1 : 0;

    return SproutTabbedLayout(
      tabs: tabs,
      selected: selectedIndex,
      onSelected: (index) => NavigationProvider.updateQueryParameters(
        context,
        {'tab': index == 1 ? 'activity' : 'overview'},
      ),
      child: SproutRouteWrapper(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
        child: IndexedStack(index: selectedIndex, children: tabViews),
      ),
    );
  }

  /// Builds the top hero card featuring account identification and the NetWorthCard
  Widget _buildBalanceHeroCard(
    ThemeData theme,
    AsyncValue<AccountChartData> combinedData,
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
                      AccountIcon(widget.account, size: 36),
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.account.name,
                                    style: theme.textTheme.labelLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.edit, size: 14),
                                  onPressed: () => showSproutEditDialog(
                                    context: context,
                                    title: "Edit Account Name",
                                    label: "Account Name",
                                    currentValue: widget.account.name,
                                    icon: Icons.account_balance_wallet,
                                    onSave: (values) async {
                                      final oldName = widget.account.name;
                                      try {
                                        setState(() =>
                                            widget.account.name = values.first);
                                        await ref
                                            .read(accountsProvider.notifier)
                                            .edit(widget.account);
                                      } catch (e) {
                                        setState(() =>
                                            widget.account.name = oldName);
                                        ref
                                            .read(
                                                notificationsProvider.notifier)
                                            .openWithAPIException(e);
                                      }
                                    },
                                  ),
                                ),
                              ],
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
          SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                child: AccountNetWorthWidget(
                  account: widget.account,
                  combinedData: combinedData,
                ),
              ))
        ],
      ),
    );
  }

  /// Builds the account overview information
  Widget _buildOverviewSection(ThemeData theme) {
    final account = widget.account;
    final institution = account.institution;
    final accountProvider = ref.read(accountsProvider.notifier);
    final providers = ref.watch(providerConfigProvider).value;
    final provider =
        providers?.firstWhereOrNull((x) => x.dbType == account.provider);
    final allHistoryAsync = ref.watch(historicalAccountDataProvider);
    final timelineAsync = ref.watch(accountTimelineProvider(widget.account.id));

    final AsyncValue<AccountChartData> combinedChartData = allHistoryAsync.when(
      data: (historyList) {
        return timelineAsync.when(
          data: (timelineList) {
            final accountHistory = historyList
                ?.firstWhereOrNull((h) => h.connectedId == widget.account.id);
            return AsyncValue.data(
                (history: accountHistory, timeline: timelineList));
          },
          error: (err, stack) => AsyncValue.error(err, stack),
          loading: () => const AsyncValue.loading(),
        );
      },
      error: (err, stack) => AsyncValue.error(err, stack),
      loading: () => const AsyncValue.loading(),
    );

    return ListView(
      padding: EdgeInsets.only(bottom: 24 + _mobileTabScrollInset),
      children: [
        // Notifications
        _buildNotifications(theme),
        // Top card
        _buildBalanceHeroCard(theme, combinedChartData),

        // Configuration Box
        SproutCard(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              spacing: 8,
              children: [
                // Account type Dropdown
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Text("Account Type",
                          style: theme.textTheme.titleSmall),
                    ),
                    SizedBox(
                      width: 240,
                      child: DropdownButtonFormField<AccountTypeEnum>(
                        value: account.type,
                        isDense: true,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        items: AccountTypeEnum.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.value.toTitleCase,
                                style: theme.textTheme.bodyMedium),
                          );
                        }).toList(),
                        onChanged: (newType) {
                          if (newType != null && newType != account.type) {
                            setState(() => account.type = newType);
                            accountProvider.edit(account);
                          }
                        },
                      ),
                    ),
                  ],
                ),

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
                if (account.type == AccountTypeEnum.loan ||
                    account.type == AccountTypeEnum.credit)
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
                          key:
                              Key("${account.id}_rate_${account.interestRate}"),
                          initialValue: account.interestRate?.toString(),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.percent, size: 18),
                            isDense: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
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

                // Institution options for this account
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text("Institution Logo Style",
                            style: theme.textTheme.titleSmall),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: InstitutionIconType.values.map((type) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<InstitutionIconType>(
                                value: type,
                                groupValue: institution.iconType,
                                visualDensity: VisualDensity.compact,
                                onChanged: (value) async {
                                  if (value == null ||
                                      institution.iconType == value) return;
                                  final oldType = institution.iconType;
                                  setState(() => institution.iconType = value);
                                  try {
                                    await ref
                                        .read(institutionsProvider.notifier)
                                        .updateIconType(
                                          institution.id,
                                          value,
                                        );
                                  } catch (e) {
                                    setState(
                                        () => institution.iconType = oldType);
                                    ref
                                        .read(notificationsProvider.notifier)
                                        .openWithAPIException(e);
                                  }
                                },
                              ),
                              Text(type.value.toTitleCase,
                                  style: theme.textTheme.bodyMedium),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Provider info
                if (provider != null) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      children: [
                        Text("Provider", style: theme.textTheme.bodyMedium),
                        const Spacer(),
                        ProviderDisplay(
                          providerType: account.provider,
                          iconSize: 24,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds notifications to display for the account content
  Widget _buildNotifications(ThemeData theme) {
    final List<Widget> notifications = [];
    final hasAnError = widget.account.hasProblem;

    if (hasAnError) {
      final String message;
      final VoidCallback? onTap;

      if (widget.account.institution.hasError) {
        message =
            "Connection issue: ${widget.account.institution.name} requires re-authentication to continue syncing.";
        onTap = widget.onUpdateConnection;
      } else {
        message =
            "This account was missing from the latest provider sync and has been archived. You'll need to re-add this account for it to show back up.";
        onTap = null;
      }

      notifications.add(
        SproutNotificationWidget(
          SproutNotification(
            message,
            theme.colorScheme.error,
            theme.colorScheme.onError,
            icon: widget.account.institution.hasError
                ? Icons.warning_amber_rounded
                : Icons.archive_outlined,
            onClick: onTap,
          ),
          allowMultiLine: true,
        ),
      );
    }

    return Column(spacing: 0, children: notifications);
  }

  /// Builds the transactions to display related to this account
  Widget _buildTransactionSection(BuildContext context, WidgetRef ref) {
    return TransactionsPage(
      accountId: widget.account.id,
      padding: EdgeInsetsGeometry.zero,
      bottomScrollPadding: _mobileTabScrollInset,
    );
  }

  /// Returns a badge that displays what type of account this is
  Widget _getTypeBadge(ThemeData theme) {
    final type = widget.account.type;
    var typeString = type.value;
    if (type == AccountTypeEnum.depository) typeString = "Cash";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(8)),
      child: Text(
        typeString.toTitleCase,
        style: theme.textTheme.labelSmall
            ?.copyWith(color: theme.colorScheme.onSecondary),
      ),
    );
  }
}
