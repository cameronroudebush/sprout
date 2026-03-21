import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_logo.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/holding/widgets/account_holding_list.dart';
import 'package:sprout/holding/widgets/market_indices_bar.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/line_chart.dart';
import 'package:sprout/shared/widgets/charts/range_selector.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accounts = ref.watch(accountsProvider).value?.accounts ?? [];

    return SproutRouteWrapper(
        child: Column(
      children: [
        // Major indices
        const MajorIndicesBarWidget(),
        // Performance Chart for selected symbol
        _buildPerformanceChart(theme),

        const Divider(),

        // The actual display content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              spacing: 8,
              children: [
                if (accounts.isEmpty)
                  Center(
                    child: SizedBox(
                      height: 164,
                      child: SproutCard(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            spacing: 12,
                            children: [
                              Icon(Icons.show_chart, size: 64, color: theme.colorScheme.primary),
                              const Text("No accounts found to choose from", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (accounts.isNotEmpty)
                  // Account Sections
                  ...accounts.where((a) => a.type == AccountTypeEnum.investment).map((account) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Row(
                            spacing: 12,
                            children: [
                              AccountLogo(account),
                              Text(account.name, style: Theme.of(context).textTheme.titleMedium),
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
        ),
      ],
    ));
  }

  /// Builds the performance chart to display for the current selected symbol
  Widget _buildPerformanceChart(ThemeData theme) {
    if (_selectedHolding == null) {
      return const SproutCard(
        child: SizedBox(height: 200, child: Center(child: Text("Select a holding below to view performance"))),
      );
    }
    final timelineAsync = ref.watch(holdingTimelineProvider(_selectedHolding!.id));

    final userConfig = ref.watch(userConfigProvider).value;
    final privateMode = userConfig?.privateMode ?? false;

    return SproutCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: timelineAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Error: $err")),
          data: (points) {
            final chartData = {for (final p in points) p.date: p.value};
            return Column(
              children: [
                Row(
                  spacing: 4,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: const SizedBox.shrink()),
                    Column(
                      children: [
                        Text(
                          _selectedHolding!.account.name,
                          style: theme.textTheme.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _selectedHolding!.symbol,
                          style: theme.textTheme.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [ChartRangeSelector()]),
                    ),
                  ],
                ),
                SproutLineChart(
                  height: 125,
                  data: chartData,
                  chartRange: userConfig?.netWorthRange ?? ChartRangeEnum.oneMonth,
                  showYAxis: true,
                  showXAxis: true,
                  applyPosNegColors: true,
                  formatValue: (val) => val.toCurrency(privateMode),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
