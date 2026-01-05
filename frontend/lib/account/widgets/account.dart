import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/dialog/account_delete.dart';
import 'package:sprout/account/dialog/account_error.dart';
import 'package:sprout/account/model/account_extensions.dart';
import 'package:sprout/account/widgets/account_logo.dart';
import 'package:sprout/account/widgets/account_sub_type.dart';
import 'package:sprout/account/widgets/institution_error.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/charts/line_chart.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/scroll.dart';
import 'package:sprout/core/widgets/state_tracker.dart';
import 'package:sprout/core/widgets/tabs.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/holding/widgets/account.dart';
import 'package:sprout/net-worth/model/entity_history_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/net-worth/widgets/net_worth_text.dart';
import 'package:sprout/net-worth/widgets/range_selector.dart';
import 'package:sprout/transaction/widgets/overview.dart';
import 'package:sprout/user/user_config_provider.dart';

/// Renders a holding display for a specific account
class AccountWidget extends StatefulWidget {
  /// The account we must have data from
  final Account account;

  const AccountWidget(this.account, {super.key});

  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

/// A page that displays information about the given account
class _AccountWidgetState extends StateTracker<AccountWidget> {
  Holding? _selectedHolding;
  Account get account => widget.account;

  @override
  Map<dynamic, DataRequest> get requests => {
    'holdings': DataRequest<HoldingProvider, (List<Holding>?, List<EntityHistory>?)>(
      provider: ServiceLocator.get<HoldingProvider>(),
      onLoad: (p, force) => p.populateDataForAccount(account),
      getFromProvider: (p) {
        // Trick the loading so we don't load holding data for non holding accounts
        if (account.type != AccountTypeEnum.investment) {
          return ([], []);
        }
        final val = p.getHoldingDataForAccount(account);
        if (val.$1 == null || val.$2 == null) return null;
        return val;
      },
    ),
  };

  /// Returns the tab content for the overview display
  Widget _buildOverviewContent(
    BuildContext context,
    NetWorthProvider netWorthProvider,
    UserConfigProvider userConfigProvider,
  ) {
    final chartRange = userConfigProvider.userDefaultChartRange;
    final data = netWorthProvider.historicalAccountData?.firstWhereOrNull((e) => e.connectedId == account.id);
    final accountDataForRange = data?.getValueByFrame(chartRange);

    num accountValChange = accountDataForRange?.valueChange ?? 0;
    num accountPercentChange = accountDataForRange?.percentChange ?? 0;
    if (account.isNegativeNetWorth) {
      accountValChange = -accountValChange;
      accountPercentChange = -accountPercentChange;
    }

    return SproutScrollView(
      padding: EdgeInsets.zero,
      child: SproutCard(
        child: Padding(
          padding: EdgeInsetsGeometry.all(12),
          child: accountDataForRange == null
              ? SizedBox(height: 250, child: TextWidget(text: "Failed to locate any account history"))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 24,
                  children: [
                    NetWorthTextWidget(
                      chartRange,
                      account.balance,
                      accountPercentChange,
                      accountValChange,
                      title: "Account Value",
                    ),
                    SproutLineChart(
                      data: accountDataForRange.historyDate,
                      chartRange: chartRange,
                      formatValue: (value) => getFormattedCurrency(value),
                      showGrid: true,
                      showXAxis: true,
                      height: 150,
                    ),
                    ChartRangeSelector(
                      selectedChartRange: chartRange,
                      onRangeSelected: (value) {
                        userConfigProvider.updateChartRange(value);
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Returns the tab content for the transactions display
  Widget _buildTransactionContent(BuildContext context) {
    return Column(children: [TransactionsOverview(account: account)]);
  }

  /// Returns the tab content for the holdings display
  Widget _buildHoldingsContent(
    BuildContext context,
    HoldingProvider holdingProvider,
    UserConfigProvider userConfigProvider,
  ) {
    final (holdings, holdingsOT) = holdingProvider.getHoldingDataForAccount(account);

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (holdings == null || holdingsOT == null) {
      return Center(
        child: Text("No holdings found", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      );
    }

    // Set selected holding if we can
    if (holdings.isNotEmpty && _selectedHolding == null) {
      _selectedHolding = holdings[0];
    }

    final chartRange = userConfigProvider.userDefaultChartRange;
    final selectedHoldingOT = holdingsOT.firstWhereOrNull((ot) => ot.connectedId == _selectedHolding?.id);
    final selectedHolding = holdings.firstWhereOrNull((h) => h.id == _selectedHolding?.id);
    final holdingDataForRange = selectedHoldingOT?.getValueByFrame(chartRange);
    return SproutScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          /// Overtime value of the selected account
          holdings.isEmpty
              ? SizedBox.shrink()
              : selectedHolding == null
              ? TextWidget(text: "No Holding Selected")
              : SproutCard(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(12),
                    child: holdingDataForRange == null
                        ? SizedBox(height: 250, child: TextWidget(text: "Failed to locate any holding history"))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 24,
                            children: [
                              NetWorthTextWidget(
                                chartRange,
                                selectedHolding.marketValue,
                                holdingDataForRange.percentChange,
                                holdingDataForRange.valueChange,
                                title: "${selectedHolding.symbol} Value",
                              ),
                              SproutLineChart(
                                data: holdingDataForRange.historyDate,
                                chartRange: chartRange,
                                formatValue: (value) => getFormattedCurrency(value),
                                showGrid: true,
                                showXAxis: true,
                                height: 150,
                              ),
                              ChartRangeSelector(
                                selectedChartRange: chartRange,
                                onRangeSelected: (value) {
                                  userConfigProvider.updateChartRange(value);
                                },
                              ),
                            ],
                          ),
                  ),
                ),

          HoldingAccount(
            account,
            holdings,
            displayAccountHeader: false,
            selectedHolding: _selectedHolding,
            onHoldingClick: (holding) {
              setState(() {
                _selectedHolding = holding;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<UserConfigProvider, AccountProvider, NetWorthProvider, HoldingProvider>(
      builder: (context, userConfigProvider, accountProvider, netWorthProvider, holdingProvider, child) {
        final List<String> tabs = ["Overview", "Transactions"];
        final List<Widget> tabContents = [
          _buildOverviewContent(context, netWorthProvider, userConfigProvider),
          _buildTransactionContent(context),
        ];

        if (account.type == AccountTypeEnum.investment) {
          tabs.add("Holdings");
          tabContents.add(_buildHoldingsContent(context, holdingProvider, userConfigProvider));
        }

        return Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppTheme.maxDesktopSize),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Top Bar of Account info
                SproutCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        AccountLogoWidget(account),

                        // Name and Institution
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 4,
                                children: [
                                  Flexible(
                                    child: TextWidget(
                                      text: account.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (account.institution.hasError) ...[
                                    InstitutionError(institution: account.institution),
                                  ],
                                ],
                              ),
                              TextWidget(
                                text: account.institution.name,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        // Controls
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          spacing: 12,
                          children: [
                            // Subtype Selector
                            SizedBox(
                              width: 200,
                              child: AccountSubTypeSelect(
                                account,
                                onChanged: (newSubType) {
                                  account.subType = newSubType;
                                  accountProvider.edit(account);
                                },
                              ),
                            ),

                            // Action Buttons
                            Wrap(
                              spacing: 8,
                              alignment: WrapAlignment.end,
                              children: [
                                // Fix Account Button
                                if (true)
                                  SproutTooltip(
                                    message: "Opens a dialog to fix this account via the provider.",
                                    child: FilledButton.icon(
                                      icon: const Icon(Icons.build_circle_outlined, size: 16),
                                      label: const Text("Fix"),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.error,
                                        foregroundColor: Theme.of(context).colorScheme.onError,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (_) => AccountErrorDialog(account: account),
                                        );
                                      },
                                    ),
                                  ),

                                // Delete Button
                                FilledButton.icon(
                                  icon: Icon(Icons.delete_outline, size: 16),
                                  label: Text("Delete"),
                                  style: AppTheme.errorButton,
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (_) => AccountDeleteDialog(account: account),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Render the tabs for the different content views
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ScrollableTabsWidget(tabs, tabContents, initialIndex: 0);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
