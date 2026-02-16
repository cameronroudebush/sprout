import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_group.dart';
import 'package:sprout/account/widgets/accounts.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/charts/line_chart.dart';
import 'package:sprout/core/provider/provider_services.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/fab.dart';
import 'package:sprout/core/widgets/state_tracker.dart';
import 'package:sprout/core/widgets/tabs.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/net-worth/widgets/net_worth_text.dart';
import 'package:sprout/net-worth/widgets/range_selector.dart';
import 'package:sprout/user/user_config_provider.dart';

class AccountsOverview extends StatefulWidget {
  final AccountTypeEnum? defaultAccountType;

  const AccountsOverview({super.key, this.defaultAccountType});

  @override
  State<AccountsOverview> createState() => _AccountsOverviewState();
}

class _AccountsOverviewState extends StateTracker<AccountsOverview> with SproutProviders {
  @override
  Map<dynamic, DataRequest> get requests => {
    'accounts': DataRequest<AccountProvider, List<Account>>(
      provider: accountProvider,
      onLoad: (p, force) => p.populateLinkedAccounts(),
      getFromProvider: (p) => p.linkedAccounts,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<UserConfigProvider>(
      builder: (context, userConfigProvider, child) {
        final accountTypes = AccountTypeEnum.values;
        final accountTypesContent = accountTypes.map((a) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: FloatingActionButtonWidget.padding),
            child: _AccountTypeTab(accountType: a),
          );
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
}

/// A dedicated widget for the tab content.
class _AccountTypeTab extends StatefulWidget {
  final AccountTypeEnum accountType;

  const _AccountTypeTab({required this.accountType});

  @override
  State<_AccountTypeTab> createState() => _AccountTypeTabState();
}

class _AccountTypeTabState extends State<_AccountTypeTab> {
  Future<Map<DateTime, num>>? _dataFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future here so it only fires once when the tab is first built
    _dataFuture = _loadAndCombineData();
  }

  Future<Map<DateTime, num>> _loadAndCombineData() async {
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    final netWorthProvider = Provider.of<NetWorthProvider>(context, listen: false);

    // Filter accounts for this specific tab
    final accountsForType = accountProvider.linkedAccounts
        .where((element) => element.type == widget.accountType)
        .toList();

    final Map<DateTime, num> combinedData = {};

    for (final account in accountsForType) {
      var timeline = netWorthProvider.getAccountTimelineData(account.id);
      if (timeline == null) {
        await netWorthProvider.populateAccountTimelineData(account.id);
        timeline = netWorthProvider.getAccountTimelineData(account.id);
      }
      if (timeline != null) {
        for (final p in timeline) {
          combinedData.update(p.date, (value) => value + p.value, ifAbsent: () => p.value);
        }
      }
    }
    return combinedData;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserConfigProvider, AccountProvider, NetWorthProvider>(
      builder: (context, userConfigProvider, accountProvider, netWorthProvider, child) {
        final chartRange = userConfigProvider.userDefaultChartRange;
        final accountsForType = accountProvider.linkedAccounts
            .where((element) => element.type == widget.accountType)
            .toList();

        return FutureBuilder<Map<DateTime, num>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
            }

            final data = snapshot.data ?? {};
            final historyForRange = accountsForType
                .map(
                  (account) => netWorthProvider.historicalAccountData?.firstWhereOrNull(
                    (element) => element.connectedId == account.id,
                  ),
                )
                .nonNulls
                .toList();

            final groupCalc = AccountGroupWidget.calculate(historyForRange, accountsForType, chartRange);
            final netWorth = groupCalc.totalBalance;
            double totalChange = groupCalc.totalChange;
            final percentageChange = groupCalc.percentageChange;

            if (widget.accountType == AccountTypeEnum.loan || widget.accountType == AccountTypeEnum.credit) {
              totalChange *= -1;
            }

            return Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
              child: Column(
                children: [
                  SproutCard(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0, right: 12, left: 12, bottom: 12),
                      child: Column(
                        spacing: 12,
                        children: data.isEmpty
                            ? [
                                SizedBox(
                                  height: 150,
                                  child: Center(child: Text("No ${formatAccountType(widget.accountType)} Accounts")),
                                ),
                              ]
                            : [
                                NetWorthTextWidget(
                                  chartRange,
                                  netWorth,
                                  percentageChange,
                                  totalChange,
                                  title: "${formatAccountType(widget.accountType)} Accounts Value",
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
                                    userConfigProvider.updateChartRange(value);
                                  },
                                ),
                              ],
                      ),
                    ),
                  ),
                  AccountsWidget(
                    allowCollapse: false,
                    netWorthPeriod: chartRange,
                    accountType: widget.accountType,
                    showGroupTitles: false,
                    shouldRequestNewData: false,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
