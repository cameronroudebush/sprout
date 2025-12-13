import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_group.dart';
import 'package:sprout/account/widgets/accounts.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/charts/line_chart.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/state_tracker.dart';
import 'package:sprout/core/widgets/tabs.dart';
import 'package:sprout/net-worth/model/entity_history_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/net-worth/widgets/net_worth_text.dart';
import 'package:sprout/net-worth/widgets/range_selector.dart';
import 'package:sprout/user/user_config_provider.dart';

/// The main accounts display that contains the chart along side the actual accounts list
class AccountsOverview extends StatefulWidget {
  /// The account type tab to go to by default
  final AccountTypeEnum? defaultAccountType;

  const AccountsOverview({super.key, this.defaultAccountType});

  @override
  State<AccountsOverview> createState() => _AccountsOverviewState();
}

class _AccountsOverviewState extends StateTracker<AccountsOverview> {
  @override
  Map<dynamic, DataRequest> get requests => {
    'accounts': DataRequest<AccountProvider, List<Account>>(
      provider: ServiceLocator.get<AccountProvider>(),
      onLoad: (p, force) => p.populateLinkedAccounts(),
      getFromProvider: (p) => p.linkedAccounts,
    ),
    'history': DataRequest<NetWorthProvider, List<EntityHistory>?>(
      provider: ServiceLocator.get<NetWorthProvider>(),
      onLoad: (p, force) => p.populateHistoricalAccountData(),
      getFromProvider: (p) => p.historicalAccountData,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserConfigProvider, AccountProvider, NetWorthProvider>(
      builder: (context, userConfigProvider, accountProvider, netWorthProvider, child) {
        final accountTypes = AccountTypeEnum.values;
        final accountTypesContent = accountTypes.map((a) {
          return _buildTabContent(context, a, userConfigProvider, accountProvider, netWorthProvider);
        }).toList();
        final initialIndex = widget.defaultAccountType == null ? 0 : accountTypes.indexOf(widget.defaultAccountType!);
        return Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppTheme.maxDesktopSize),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ScrollableTabsWidget(
                  accountTypes.map((el) => formatAccountType(el)).toList(),
                  accountTypesContent,
                  initialIndex: initialIndex == -1 ? 0 : initialIndex,
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Helper method to create the tab content for each account type
  Widget _buildTabContent(
    BuildContext context,
    AccountTypeEnum accountType,
    UserConfigProvider provider,
    AccountProvider accountProvider,
    NetWorthProvider netWorthProvider,
  ) {
    final chartRange = provider.userDefaultChartRange;
    final accountsForType = accountProvider.linkedAccounts.where((element) => element.type == accountType).toList();
    // Build the net worth data for these accounts
    final historyForRange = accountsForType
        .map(
          (account) =>
              netWorthProvider.historicalAccountData?.firstWhereOrNull((element) => element.connectedId == account.id),
        )
        .nonNulls
        .toList();

    // Flatten the data so the line chart can display the combined net worth for these accounts
    final Map<DateTime, num> data = {};
    for (final entityHistory in historyForRange) {
      final history = entityHistory.getValueByFrame(chartRange).historyDate;
      for (final historyPoint in history.entries) {
        data.update(historyPoint.key, (value) => value + historyPoint.value, ifAbsent: () => historyPoint.value);
      }
    }

    final groupCalc = AccountGroupWidget.calculate(historyForRange, accountsForType, chartRange);
    final netWorth = groupCalc.totalBalance;
    double totalChange = groupCalc.totalChange;
    final percentageChange = groupCalc.percentageChange;
    if (accountType == AccountTypeEnum.loan || accountType == AccountTypeEnum.credit) totalChange *= -1;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
        child: Column(
          children: [
            // Render net worth chart
            SproutCard(
              child: Padding(
                padding: const EdgeInsets.only(top: 0, right: 12, left: 12, bottom: 12),
                child: Column(
                  spacing: 12,
                  children: isLoading
                      ? [SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))]
                      : data.isEmpty
                      ? [
                          SizedBox(
                            height: 150,
                            child: Center(child: Text("No ${formatAccountType(accountType)} Accounts")),
                          ),
                        ]
                      : [
                          NetWorthTextWidget(
                            chartRange,
                            netWorth,
                            percentageChange,
                            totalChange,
                            title: "${formatAccountType(accountType)} Accounts Value",
                            applyColor: false,
                          ),
                          SproutLineChart(
                            data: data,
                            chartRange: chartRange,
                            formatValue: (value) => getFormattedCurrency(value),
                            showYAxis: false,
                            showXAxis: true,
                            formatYAxis: (value) => getShortFormattedCurrency(value),
                            yAxisSize: 50,
                            showGrid: true,
                          ),
                          ChartRangeSelector(
                            selectedChartRange: chartRange,
                            onRangeSelected: (value) {
                              provider.updateChartRange(value);
                            },
                          ),
                        ],
                ),
              ),
            ),
            // Render accounts
            AccountsWidget(
              allowCollapse: false,
              netWorthPeriod: chartRange,
              accountType: accountType,
              showGroupTitles: false,
              // We should already have the data we need
              shouldRequestNewData: false,
            ),
          ],
        ),
      ),
    );
  }
}
