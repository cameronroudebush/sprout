import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_icon.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/holding/widgets/account_holding_list.dart';
import 'package:sprout/holding/widgets/market_indices_bar.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/line_chart.dart';
import 'package:sprout/shared/widgets/charts/models/line_chart_data.dart';
import 'package:sprout/shared/widgets/charts/processors/line_chart_processor.dart';
import 'package:sprout/shared/widgets/charts/range_selector.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/user/user_config_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accounts = ref.watch(accountsProvider).value?.accounts ?? [];

    // Filter to just investment accounts as those contain holdings
    final investmentAccounts = accounts.where((a) => a.type == AccountTypeEnum.investment).toList();

    // Aggregating all holdings across all investment accounts to check if we have data
    final hasHoldings = investmentAccounts.any((account) {
      return ref.watch(accountHoldingsProvider(account.id).select((state) => state.value?.isNotEmpty == true));
    });

    // Auto select default holding
    if (!_hasInitialSelection && hasHoldings) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedHolding == null) {
          for (final account in investmentAccounts) {
            final holdings = ref.read(accountHoldingsProvider(account.id)).value ?? [];
            if (holdings.isNotEmpty) {
              setState(() {
                _selectedHolding = holdings.first;
                _hasInitialSelection = true;
              });
              break; // Stop after finding the first one
            }
          }
        }
      });
    }

    return Column(
      children: [
        SproutRouteWrapper(
            child: Column(
          children: [
            // Major indices
            const MajorIndicesBarWidget(),
            // Performance Chart for selected symbol
            if (accounts.isNotEmpty && hasHoldings) _buildPerformanceChart(theme),
            const Divider(),
          ],
        )),

        // The actual display content
        Expanded(
            child: SingleChildScrollView(
          child: SproutRouteWrapper(
            child: Column(
              spacing: 8,
              children: [
                // No accounts at all
                if (accounts.isEmpty)
                  _buildWarningCard(
                    theme,
                    icon: Icons.account_balance_wallet_outlined,
                    message: "No accounts found to choose from",
                  )
                // Accounts exist, but no holdings in any of them
                else if (!hasHoldings)
                  _buildWarningCard(
                    theme,
                    icon: Icons.pie_chart_outline,
                    message: "No holdings found in your investment accounts",
                  )

                // Render the list
                else
                  ...investmentAccounts.map((account) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
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
          ),
        )),
      ],
    );
  }

  /// Helper to build the warning UI
  Widget _buildWarningCard(ThemeData theme, {required IconData icon, required String message}) {
    return Center(
      child: SizedBox(
        height: 180,
        child: SproutCard(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: [
                Icon(icon, size: 48, color: theme.colorScheme.secondary),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the performance chart to display for the current selected symbol
  Widget _buildPerformanceChart(ThemeData theme) {
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
    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return SproutCard(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: timelineAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text("Error: $err")),
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

              return Column(
                children: [
                  Row(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(child: SizedBox.shrink()),
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedHoldingAccount?.name ?? "Unknown account",
                              style: theme.textTheme.labelMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              _selectedHolding!.symbol,
                              style: theme.textTheme.labelMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [ChartRangeSelector()],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: isDesktop ? 200 : 150,
                      child: SproutLineChart(
                        series: seriesList,
                        chartRange: userConfig?.netWorthRange ?? ChartRangeEnum.oneMonth,
                        showYAxis: true,
                        showXAxis: true,
                        showGrid: true,
                        showLegend: false,
                        formatValue: (val) => formatter.format(val, compact: true),
                      )),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}
