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
import 'package:sprout/core/widgets/page_loading.dart';
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
  /// The ID of the account we want to display data for
  final String accountId;

  const AccountWidget(this.accountId, {super.key});

  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

/// A page that displays information about the given account
class _AccountWidgetState extends StateTracker<AccountWidget> {
  Holding? _selectedHolding;

  /// Returns the account based on our current Id
  Account get account {
    return ServiceLocator.get<AccountProvider>().linkedAccounts.firstWhereOrNull((x) => x.id == widget.accountId)!;
  }

  @override
  Map<dynamic, DataRequest> get requests => {
    'account': DataRequest<AccountProvider, Account>(
      provider: ServiceLocator.get<AccountProvider>(),
      onLoad: (p, force) async {
        await p.populateLinkedAccounts(); // Populate accounts
        return account;
      },
      getFromProvider: (p) => account,
    ),
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
    final data = netWorthProvider.historicalAccountData?.firstWhereOrNull((e) => e.connectedId == widget.accountId);
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
        if (isLoading) return PageLoadingWidget();

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 12,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 16,
                          children: [
                            AccountLogoWidget(account),

                            // Name and Institution
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.name,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    account.institution.name,
                                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Sub-type Selector
                        AccountSubTypeSelect(
                          account,
                          onChanged: (newSubType) {
                            account.subType = newSubType;
                            accountProvider.edit(account);
                          },
                        ),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          spacing: 24,
                          children: [
                            // Error Status & Fix Button
                            if (account.institution.hasError) ...[
                              SproutTooltip(
                                message: "Opens a dialog to fix this account via the provider.",
                                child: FilledButton.icon(
                                  icon: const Icon(Icons.build_circle_outlined, size: 16),
                                  label: const Text("Fix"),
                                  style: AppTheme.errorButton,
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (_) => AccountErrorDialog(account: account),
                                    );
                                  },
                                ),
                              ),
                              InstitutionError(institution: account.institution),
                            ],

                            // Delete Button
                            FilledButton.icon(
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: const Text("Delete"),
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
