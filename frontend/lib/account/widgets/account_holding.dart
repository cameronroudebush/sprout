import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/charts/line_chart.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/provider_services.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/state_tracker.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/net-worth/model/historical_data_point_extensions.dart';

/// A class that displays account holding timeline information for a specific holding
class AccountHoldingTimeline extends StatefulWidget {
  final Holding holding;
  final ChartRangeEnum chartRange;

  const AccountHoldingTimeline(this.holding, this.chartRange, {super.key});

  @override
  State<AccountHoldingTimeline> createState() => _AccountHoldingTimelineState();
}

class _AccountHoldingTimelineState extends StateTracker<AccountHoldingTimeline> with SproutProviders {
  @override
  Map<dynamic, DataRequest<BaseProvider<dynamic>, dynamic>> get requests => {
    'timeline': DataRequest<HoldingProvider, List<HistoricalDataPoint>>(
      provider: holdingProvider,
      onLoad: (p, force) => p.populateHoldingTimelineData(widget.holding.id),
      getFromProvider: (p) => p.getHoldingTimelineData(widget.holding.id),
    ),
  };

  @override
  get widgetName => "${super.widgetName}_${widget.holding.id}";

  @override
  void didUpdateWidget(covariant AccountHoldingTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.holding.id != oldWidget.holding.id) loadData();
  }

  @override
  Widget build(BuildContext context) {
    final timeline = holdingProvider.getHoldingTimelineData(widget.holding.id);

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (timeline == null) {
      return Center(
        child: Text("No historical data found", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      );
    }

    return SproutLineChart(
      data: HistoricalDataPointExtensions.toMap(timeline),
      chartRange: widget.chartRange,
      formatValue: (value) => getFormattedCurrency(value),
      showGrid: true,
      showXAxis: true,
      height: 150,
    );
  }

  @override
  void dispose() {
    super.dispose();
    StateTracker.lastUpdateTimes.remove(widgetName);
  }
}
