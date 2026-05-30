import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_icon.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/holding/widgets/account_holding_list.dart';
import 'package:sprout/holding/widgets/market_indices_bar.dart';
import 'package:sprout/holding/widgets/market_indicies_timeline.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/header.dart';
import 'package:sprout/shared/widgets/charts/line_chart.dart';
import 'package:sprout/shared/widgets/charts/models/line_chart_data.dart';
import 'package:sprout/shared/widgets/charts/processors/line_chart_processor.dart';
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
                  child: _buildMarketPanel(theme, accounts, hasHoldings, isDesktop),
                ),
              ),
              const VerticalDivider(width: 32, thickness: 1),
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  child: _buildHoldingsPanel(theme, accounts, investmentAccounts, hasHoldings),
                ),
              ),
            ],
          ),
        );
      }

      return SproutRouteWrapper(
        child: Column(
          children: [
            _buildMarketPanel(theme, accounts, hasHoldings, isDesktop),
            Expanded(
              child: SingleChildScrollView(
                child: _buildHoldingsPanel(theme, accounts, investmentAccounts, hasHoldings),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Combines index trends and charts without nesting inner ScrollViews
  Widget _buildMarketPanel(ThemeData theme, List<Account> accounts, bool hasHoldings, bool isDesktop) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SproutRouteWrapper(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MajorIndicesBarWidget(),
              if (isDesktop) ...[
                const Divider(),
                const SizedBox(height: 300, child: SproutCard(child: MajorIndicesTimelineWidget())),
              ],
              const Divider(),
              if (accounts.isNotEmpty && hasHoldings) ...[
                _buildPerformanceChart(theme, isDesktop),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Renders the active warning cards or holdings data maps
  Widget _buildHoldingsPanel(
      ThemeData theme, List<Account> accounts, List<Account> investmentAccounts, bool hasHoldings) {
    return SproutRouteWrapper(
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (accounts.isEmpty)
            _buildWarningCard(
              theme,
              icon: Icons.account_balance_wallet_outlined,
              message: "No accounts found to choose from",
            )
          else if (!hasHoldings)
            _buildWarningCard(
              theme,
              icon: Icons.pie_chart_outline,
              message: "No holdings found in your investment accounts",
            )
          else
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
    return SproutCard(
      child: timelineAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (points) {
          final dataMap = {for (final p in points) p.date: p.value};
          final filteredHistorical =
              LineChartDataProcessor.filterHistoricalData(dataMap, userConfig?.netWorthRange ?? ChartRangeEnum.oneDay);
          final data = LineChartDataProcessor.prepareChartData(filteredHistorical);

          final List<SproutChartSeries> seriesList = [
            SproutChartSeries(
              data: data,
              label: _selectedHolding!.symbol,
              config: LineSeriesConfig(color: theme.colorScheme.primary),
            ),
          ];

          if (data.spots.isNotEmpty) seriesList.add(LineChartDataProcessor.computeAverageData(data));

          return SizedBox(
              height: isDesktop ? 300 : 150,
              child: SproutLineChart(
                series: seriesList,
                header: ChartHeader(
                  title: selectedHoldingAccount?.name ?? "Unknown account",
                  subheader: _selectedHolding!.symbol,
                ),
                chartRange: userConfig?.netWorthRange ?? ChartRangeEnum.oneMonth,
                showYAxis: true,
                showXAxis: true,
                showGrid: true,
                showLegend: false,
                formatValue: (val) => formatter.format(val, compact: true),
              ));
        },
      ),
    );
  }
}
