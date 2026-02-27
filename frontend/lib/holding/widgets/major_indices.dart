import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sprout/account/widgets/account_change.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/provider_services.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/card.dart';

/// A widget that represents the major marked indices
class MajorIndicesWidget extends StatefulWidget {
  final int refreshMinutes;
  const MajorIndicesWidget({super.key, this.refreshMinutes = 2});

  @override
  State<MajorIndicesWidget> createState() => _MajorIndicesWidgetState();
}

class _MajorIndicesWidgetState extends State<MajorIndicesWidget> with SproutProviders {
  Timer? _refreshTimer;
  List<MarketIndexDto> _indices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchIndices();
    _refreshTimer = Timer.periodic(Duration(minutes: widget.refreshMinutes), (_) => _fetchIndices());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchIndices() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await holdingProvider.api.holdingControllerGetLiveMajor();
      if (mounted && results != null) {
        setState(() {
          _indices = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_indices.isEmpty) return const SizedBox.shrink();
    return SproutCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.all(6),
            child: Row(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _indices.map((x) => _buildIndexItem(x)).toList(),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(minHeight: 1),
        ],
      ),
    );
  }

  Widget _buildIndexItem(MarketIndexDto data) {
    final isClosed = data.marketState != MarketIndexDtoMarketStateEnum.REGULAR;

    return Opacity(
      opacity: isClosed ? 0.8 : 1.0,
      child: Column(
        spacing: 4,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(data.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              _buildStatusBadge(data.marketState),
            ],
          ),
          Text(getFormattedCurrency(data.price), style: const TextStyle(fontSize: 15)),
          AccountChangeWidget(totalChange: data.change, percentageChange: data.changePercent, showValue: false),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(MarketIndexDtoMarketStateEnum? state) {
    final color = state == MarketIndexDtoMarketStateEnum.REGULAR ? Colors.green : Colors.orange;
    final label = state == MarketIndexDtoMarketStateEnum.REGULAR
        ? "LIVE"
        : (state?.toString().split('.').last ?? "OFFLINE");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
