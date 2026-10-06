import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_icon.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/chat/chat_provider.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/holding/widgets/account_holding_list.dart';
import 'package:sprout/holding/widgets/holding_chart_card.dart';
import 'package:sprout/holding/widgets/holding_dividends.dart';
import 'package:sprout/holding/widgets/holding_mover.dart';
import 'package:sprout/holding/widgets/holding_pie_chart.dart';
import 'package:sprout/holding/widgets/market_indices_bar.dart';
import 'package:sprout/holding/widgets/market_indices_timeline.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/line_chart.dart';
import 'package:sprout/shared/widgets/charts/models/line_chart_data.dart';
import 'package:sprout/shared/widgets/charts/processors/line_chart_processor.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';
import 'package:sprout/shared/widgets/charts/util/range_selector.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/tab_selector.dart';
import 'package:sprout/user/user_config_provider.dart';

// Available tabs
/// Holdings page sections synchronized with the `tab` query parameter.
enum HoldingsTab { holdings, overview }

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

  // Separate scroll controllers for mobile and desktop views
  final ScrollController _mobileScrollController = ScrollController();
  final ScrollController _desktopScrollController = ScrollController();

  @override
  void dispose() {
    _mobileScrollController.dispose();
    _desktopScrollController.dispose();
    super.dispose();
  }

  void _resetScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mobileScrollController.hasClients) {
        _mobileScrollController.jumpTo(0);
      }
      if (_desktopScrollController.hasClients) {
        _desktopScrollController.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTab = NavigationProvider.queryParameter(context, 'tab') ==
            HoldingsTab.holdings.name
        ? HoldingsTab.holdings
        : HoldingsTab.overview;
    final accountsAsync = ref.watch(accountsProvider);
    final isChatEnabled = ref.watch(chatEnabledProvider);

    return accountsAsync.whenDefault(
      customErrorMessage: "Failed to load investment profile",
      emptyWidget: _buildWarningCard(
        theme,
        icon: Icons.account_balance_wallet_outlined,
        message: "No accounts found to choose from",
      ),
      data: (state) {
        final accounts = state.accounts;
        bool allLoaded = true;
        final accountsWithHoldings = <Account>[];

        // Holdings can be attached to more than just crypto/investment accounts so we account for all of them here.
        for (final account in accounts) {
          final holdingAsync = ref.watch(accountHoldingsProvider(account.id));
          if (holdingAsync.isLoading) {
            allLoaded = false;
          }
          if (holdingAsync.value?.isNotEmpty == true) {
            accountsWithHoldings.add(account);
          }
        }

        if (!allLoaded) {
          return const SproutRouteWrapper(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (accountsWithHoldings.isEmpty) {
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
              for (final account in accountsWithHoldings) {
                final holdings =
                    ref.read(accountHoldingsProvider(account.id)).value ?? [];
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
          const tabs = [
            SproutTabOption(
              value: HoldingsTab.overview,
              label: 'Overview',
            ),
            SproutTabOption(
              value: HoldingsTab.holdings,
              label: 'Holdings',
            ),
          ];

          if (isDesktop) {
            return SproutRouteWrapper(
              size: SproutRouteSize.large,
              child: Column(
                children: [
                  Expanded(
                    child: currentTab == HoldingsTab.overview
                        ? SingleChildScrollView(
                            controller: _desktopScrollController,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const MajorIndicesBarWidget(),
                                SizedBox(
                                  height: 300,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Expanded(
                                        flex: 6,
                                        child: SproutCard(
                                            child:
                                                MajorIndicesTimelineWidget()),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: SproutCard(
                                          child: HoldingPieChart(
                                            investmentAccounts:
                                                accountsWithHoldings,
                                            topN: 5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isChatEnabled)
                                  SizedBox(
                                    height: 400,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      spacing: 0,
                                      children: [
                                        const Expanded(
                                          child: HoldingsChatCard(),
                                        ),
                                        Expanded(
                                          child: SproutCard(
                                            child: SingleChildScrollView(
                                              child: HoldingMoverWidget(
                                                investmentAccounts:
                                                    accountsWithHoldings,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  SproutCard(
                                    child: HoldingMoverWidget(
                                      investmentAccounts: accountsWithHoldings,
                                    ),
                                  ),
                                SproutCard(
                                  child: HoldingDividendsWidget(
                                    investmentAccounts: accountsWithHoldings,
                                    isDesktop: isDesktop,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              _buildPerformanceChart(theme, isDesktop),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: _desktopScrollController,
                                  child: _buildHoldingsPanel(
                                      theme, accountsWithHoldings),
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
            child: SproutTabbedLayout(
              tabs: tabs,
              selected: currentTab,
              onSelected: (tab) {
                NavigationProvider.updateQueryParameters(
                    context, {'tab': tab.name});
                _resetScroll();
              },
              child: Column(
                children: [
                  const MajorIndicesBarWidget(),
                  if (currentTab == HoldingsTab.holdings)
                    _buildPerformanceChart(theme, isDesktop),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _mobileScrollController,
                      key: ValueKey(currentTab),
                      padding: const EdgeInsets.only(
                        bottom: SproutTabbedLayout.mobileNavigationScrollInset,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (currentTab == HoldingsTab.holdings) ...[
                            _buildHoldingsPanel(theme, accountsWithHoldings),
                          ] else ...[
                            if (isChatEnabled)
                              const HoldingsChatCard(mobile: true),
                            SproutCard(
                                child: HoldingMoverWidget(
                                    investmentAccounts: accountsWithHoldings)),
                            const SproutCard(
                              child: SizedBox(
                                height: 250,
                                child: MajorIndicesTimelineWidget(),
                              ),
                            ),
                            if (accountsWithHoldings.isNotEmpty)
                              SproutCard(
                                child: SizedBox(
                                  height: 250,
                                  child: HoldingPieChart(
                                    investmentAccounts: accountsWithHoldings,
                                    topN: 5,
                                  ),
                                ),
                              ),
                            SproutCard(
                              child: HoldingDividendsWidget(
                                investmentAccounts: accountsWithHoldings,
                                isDesktop: isDesktop,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  /// Displays a list of holdings the current user has across their accounts
  Widget _buildHoldingsPanel(
      ThemeData theme, List<Account> accountsWithHoldings) {
    return SproutRouteWrapper(
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...accountsWithHoldings.map((account) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
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
  Widget _buildWarningCard(ThemeData theme,
      {required IconData icon, required String message}) {
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
        child: SizedBox(
            height: 200,
            child: Center(
                child: Text("Select a holding below to view performance"))),
      );
    }
    final timelineAsync =
        ref.watch(holdingTimelineProvider(_selectedHolding!.id));
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
            final filteredHistorical =
                LineChartDataProcessor.filterHistoricalData(dataMap,
                    userConfig?.netWorthRange ?? ChartRangeEnum.oneDay);
            final data =
                LineChartDataProcessor.prepareChartData(filteredHistorical);

            final List<SproutChartSeries> seriesList = [
              SproutChartSeries(
                data: data,
                label: _selectedHolding!.symbol,
                config: LineSeriesConfig(color: theme.colorScheme.primary),
              ),
            ];

            if (data.spots.isNotEmpty)
              seriesList.add(LineChartDataProcessor.computeAverageData(data));

            return SproutLineChart(
              series: seriesList,
              header: SproutChartHeader(
                title: selectedHoldingAccount?.name ?? "Unknown account",
                subheader: _selectedHolding!.symbol,
                right: const ChartRangeSelector(),
                left: Tooltip(
                  constraints: const BoxConstraints(maxWidth: 280),
                  message:
                      "This is the most recent change reported by ${selectedHoldingAccount?.provider ?? "Unknown"}. This value updates less often and may lag behind live market movements.",
                  child: Icon(
                    Icons.info_outline,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
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
