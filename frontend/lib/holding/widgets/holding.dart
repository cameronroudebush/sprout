import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sprout/account/widgets/account_change.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/provider_services.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/holding/widgets/holding_logo.dart';

/// Renders a single holding with live price updates vs yesterday's stored value
class HoldingWidget extends StatefulWidget {
  final Holding holding;
  final bool isSelected;
  final Function(Holding holding)? onClick;

  /// Howe often to refresh live prices. Updating more than every 5 minutes will not result in any change as the backend cache is 5 minutes
  final int refreshMinutes;

  const HoldingWidget({
    super.key,
    required this.holding,
    this.isSelected = false,
    this.onClick,
    this.refreshMinutes = 5,
  });

  @override
  State<HoldingWidget> createState() => _HoldingWidgetState();
}

class _HoldingWidgetState extends State<HoldingWidget> with SproutProviders {
  Timer? _refreshTimer;
  MarketIndexDto? _liveData;
  bool _isLoading = false;

  Holding get holding => widget.holding;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUpdate();
    });
    _refreshTimer = Timer.periodic(Duration(minutes: widget.refreshMinutes), (_) => _fetchUpdate());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUpdate() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await holdingProvider.api.holdingControllerGetLivePrices([holding.symbol]);
      if (mounted && results != null && results.isNotEmpty) {
        setState(() {
          _liveData = results.first;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Live Calculations
    final livePrice = _liveData?.price ?? (holding.marketValue / holding.shares);
    final liveMarketValue = livePrice * holding.shares;

    // Day Change (Live Value vs. Yesterday's Stored Value)
    // We use holding.marketValue as the "base" from the last database sync
    final dayValueChange = liveMarketValue - holding.marketValue;
    final dayPercentChange = holding.marketValue != 0 ? (dayValueChange / holding.marketValue) * 100 : 0.0;

    // Total Return (Live Value vs. Original Cost Basis)
    final totalValueChange = liveMarketValue - holding.costBasis;
    final totalPercentChange = holding.costBasis != 0 ? (totalValueChange / holding.costBasis) * 100 : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final statsContent = _buildContent(
          isMobile,
          totalValueChange,
          totalPercentChange,
          livePrice,
          liveMarketValue,
          dayValueChange,
          dayPercentChange,
        );

        return InkWell(
          onTap: () => widget.onClick?.call(holding),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              spacing: 12,
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    spacing: 24,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        flex: isMobile ? 2 : 1,
                        child: Row(
                          spacing: 12,
                          children: [
                            HoldingLogoWidget(holding),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  TextWidget(
                                    text: holding.symbol,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start,
                                  ),
                                  if (_isLoading)
                                    const SizedBox(height: 2, child: LinearProgressIndicator(minHeight: 1)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(flex: isMobile ? 5 : 7, child: statsContent),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    bool isMobile,
    num totalChange,
    num totalPercent,
    num livePrice,
    num liveValue,
    num dayChange,
    num dayPercent,
  ) {
    final content = [
      _buildColumnOfContent("Shares", holding.shares.toStringAsFixed(2), row: isMobile),
      const Divider(height: 1),
      _buildColumnOfContent(
        "Live Price",
        getFormattedCurrency(livePrice),
        description: "Current market price",
        row: isMobile,
      ),
      const Divider(height: 1),
      // Day Change: Comparing Live Market Value to the Market Value stored in the holding
      _buildColumnOfContent(
        "Day Change",
        "",
        description: "Change in value since the last account sync (Yesterday)",
        child: AccountChangeWidget(totalChange: dayChange, percentageChange: dayPercent),
        row: isMobile,
      ),
      const Divider(height: 1),
      _buildColumnOfContent(
        "Market Value",
        getFormattedCurrency(liveValue),
        description: "Total value based on live price",
        row: isMobile,
      ),
      const Divider(height: 1),
      _buildColumnOfContent(
        "Total Return",
        "",
        description: "All-time performance vs Cost Basis",
        child: AccountChangeWidget(totalChange: totalChange, percentageChange: totalPercent),
        row: isMobile,
      ),
    ];

    return isMobile
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 4,
            children: content,
          )
        : Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: content);
  }

  Widget _buildColumnOfContent(
    String text,
    dynamic displayText, {
    String? description,
    Widget? child,
    bool row = false,
  }) {
    final statsContent = [if (displayText != "") TextWidget(text: displayText), if (child != null) child];
    final content = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 4,
        children: [
          TextWidget(
            text: text,
            referenceSize: 0.9,
            style: const TextStyle(color: Colors.grey),
          ),
          if (description != null)
            SproutTooltip(
              message: description,
              child: const Icon(Icons.info, size: 16, color: Colors.grey),
            ),
        ],
      ),
      row
          ? Row(spacing: 8, children: statsContent)
          : Column(crossAxisAlignment: CrossAxisAlignment.end, children: statsContent),
    ];

    return row
        ? Row(spacing: 4, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: content)
        : Column(spacing: 4, children: content);
  }
}
