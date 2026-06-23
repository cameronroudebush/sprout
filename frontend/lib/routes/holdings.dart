import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_icon.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/holding/widgets/account_holding_list.dart';
import 'package:sprout/holding/widgets/holding_dividends.dart';
import 'package:sprout/holding/widgets/holding_mover.dart';
import 'package:sprout/holding/widgets/holding_pie_chart.dart';
import 'package:sprout/holding/widgets/market_indices_bar.dart';
import 'package:sprout/holding/widgets/market_indices_timeline.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/line_chart.dart';
import 'package:sprout/shared/widgets/charts/models/line_chart_data.dart';
import 'package:sprout/shared/widgets/charts/processors/line_chart_processor.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/user/user_config_provider.dart';

// Available tabs
enum MobileMarketTab { holdings, overview }

/// This page displays an overview of all holdings related to the current user
class HoldingsPage extends ConsumerStatefulWidget {
  const HoldingsPage({super.key});

  @override
  ConsumerState<HoldingsPage> createState() => _HoldingsPageState();
}

class _HoldingsPageState extends ConsumerState<HoldingsPage> {
  /// The selected holding we're showing the performance of
  Holding? _selectedHolding;
  bool _hasInitialSelection = false;
  MobileMarketTab _currentTab = MobileMarketTab.holdings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsProvider);

    return accountsAsync.whenDefault(
      customErrorMessage: "Failed to load investment profile",
      emptyWidget: _buildWarningCard(
        theme,
        icon: Icons.account_balance_wallet_outlined,
        message: "No accounts found to choose from",
      ),
      data: (state) {
        final accounts = state.accounts;
        final investmentAccounts = accounts.where((a) => a.type == AccountTypeEnum.investment).toList();

        bool allLoaded = true;
        bool hasHoldings = false;

        for (final account in investmentAccounts) {
          final holdingAsync = ref.watch(accountHoldingsProvider(account.id));
          if (holdingAsync.isLoading) {
            allLoaded = false;
          }
          if (holdingAsync.value?.isNotEmpty == true) {
            hasHoldings = true;
          }
        }

        if (!allLoaded) {
          return const SproutRouteWrapper(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!hasHoldings) {
          return SproutRouteWrapper(
            child: _buildWarningCard(
              theme,
              icon: Icons.pie_chart_outline,
              message: "No holdings found in your investment accounts",
            ),
          );
        }

        // Auto select default holding
        if (!_hasInitialSelection) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedHolding == null) {
              for (final account in investmentAccounts) {
                final holdings = ref.read(accountHoldingsProvider(account.id)).value ?? [];
                if (holdings.isNotEmpty) {
                  setState(() {
                    _selectedHolding = holdings.first;
                    _hasInitialSelection = true;
                  });
                  break;
                }
              }
            }
          });
        }

        return SproutLayoutBuilder((isDesktop, context, constraints) {
          if (isDesktop) {
            return SproutRouteWrapper(
              size: SproutRouteSize.large,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const MajorIndicesBarWidget(),
                          const Divider(),
                          SizedBox(
                            height: 300,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Expanded(
                                  flex: 6,
                                  child: SproutCard(child: MajorIndicesTimelineWidget()),
                                ),
                                if (hasHoldings)
                                  Expanded(
                                    flex: 3,
                                    child: SproutCard(
                                      child: HoldingPieChart(
                                        investmentAccounts: investmentAccounts,
                                        topN: 5,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SproutCard(child: HoldingMoverWidget(investmentAccounts: investmentAccounts)),
                          SproutCard(
                              child: HoldingDividendsWidget(
                            investmentAccounts: investmentAccounts,
                            isDesktop: isDesktop,
                          )),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 32, thickness: 1),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        if (accounts.isNotEmpty && hasHoldings) _buildPerformanceChart(theme, isDesktop),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildHoldingsPanel(theme, investmentAccounts),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return SproutRouteWrapper(
            child: Column(
              children: [
                if (_currentTab == MobileMarketTab.holdings) ...[
                  const MajorIndicesBarWidget(),
                  if (accounts.isNotEmpty && hasHoldings) _buildPerformanceChart(theme, isDesktop),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_currentTab == MobileMarketTab.holdings) ...[
                          _buildHoldingsPanel(theme, investmentAccounts),
                        ] else ...[
                          const SproutCard(
                            child: SizedBox(
                              height: 250,
                              child: MajorIndicesTimelineWidget(),
                            ),
                          ),
                          if (hasHoldings)
                            SproutCard(
                              child: SizedBox(
                                height: 250,
                                child: HoldingPieChart(
                                  investmentAccounts: investmentAccounts,
                                  topN: 5,
                                ),
                              ),
                            ),
                          SproutCard(child: HoldingMoverWidget(investmentAccounts: investmentAccounts)),
                          SproutCard(
                              child:
                                  HoldingDividendsWidget(investmentAccounts: investmentAccounts, isDesktop: isDesktop)),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<MobileMarketTab>(
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      segments: const [
                        ButtonSegment(
                          value: MobileMarketTab.holdings,
                          label: Text('Holdings'),
                        ),
                        ButtonSegment(
                          value: MobileMarketTab.overview,
                          label: Text('Overview'),
                        ),
                      ],
                      selected: {_currentTab},
                      onSelectionChanged: (Set<MobileMarketTab> newSelection) {
                        setState(() {
                          _currentTab = newSelection.first;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  /// Displays a list of holdings the current user has across their accounts
  Widget _buildHoldingsPanel(ThemeData theme, List<Account> investmentAccounts) {
    return SproutRouteWrapper(
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...investmentAccounts.map((account) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Row(
                    spacing: 12,
                    children: [
                      AccountIcon(account),
                      Expanded(
                        child: Text(
                          account.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                AccountHoldingsList(
                  accountId: account.id,
                  selectedId: _selectedHolding?.id,
                  onSelect: (holding) {
                    setState(() {
                      _selectedHolding = holding;
                    });
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Builds a warning card if the user has no holdings
  Widget _buildWarningCard(ThemeData theme, {required IconData icon, required String message}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12,
      children: [
        Icon(icon, size: 64, color: theme.colorScheme.secondary),
        Text(
          message,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the performance chart for how the individual holding is performing over time
  Widget _buildPerformanceChart(ThemeData theme, bool isDesktop) {
    if (_selectedHolding == null) {
      return const SproutCard(
        child: SizedBox(height: 200, child: Center(child: Text("Select a holding below to view performance"))),
      );
    }
    final timelineAsync = ref.watch(holdingTimelineProvider(_selectedHolding!.id));
    final selectedHoldingAccount = ref.watch(
      accountsProvider.select<Account?>((asyncState) {
        return asyncState.value?.accounts.firstWhereOrNull(
          (a) => a.id == _selectedHolding?.accountId,
        );
      }),
    );
    final formatter = ref.watch(currencyFormatterProvider);
    final userConfig = ref.watch(userConfigProvider).value;

    final double chartHeight = isDesktop ? 300 : 200;

    return SproutCard(
      child: SizedBox(
        height: chartHeight,
        child: timelineAsync.whenDefault(
          customErrorMessage: "Error loading historical trends",
          data: (points) {
            final dataMap = {for (final p in points) p.date: p.value};
            final filteredHistorical = LineChartDataProcessor.filterHistoricalData(
                dataMap, userConfig?.netWorthRange ?? ChartRangeEnum.oneDay);
            final data = LineChartDataProcessor.prepareChartData(filteredHistorical);

            final List<SproutChartSeries> seriesList = [
              SproutChartSeries(
                data: data,
                label: _selectedHolding!.symbol,
                config: LineSeriesConfig(color: theme.colorScheme.primary),
              ),
            ];

            if (data.spots.isNotEmpty) seriesList.add(LineChartDataProcessor.computeAverageData(data));

            return SproutLineChart(
              series: seriesList,
              header: SproutChartHeader(
                title: selectedHoldingAccount?.name ?? "Unknown account",
                subheader: _selectedHolding!.symbol,
                right: Tooltip(
                  constraints: const BoxConstraints(maxWidth: 280),
                  message:
                      "This is the most recent change reported by ${selectedHoldingAccount?.provider ?? "Unknown"}. This value updates less often and may lag behind live market movements.",
                  child: Icon(
                    Icons.info_outline,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              chartRange: userConfig?.netWorthRange ?? ChartRangeEnum.oneMonth,
              showYAxis: true,
              showXAxis: true,
              showGrid: true,
              showLegend: false,
              formatValue: (val) => formatter.format(val, compact: true),
            );
          },
        ),
      ),
    );
  }
}
