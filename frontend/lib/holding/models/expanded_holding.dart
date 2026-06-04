import 'package:sprout/api/api.dart';

/// Defines a holding that contains additional information to calculate live day changes as well as additional
///   historical information.
class ExpandedHolding {
  final Holding holding;
  final Account? account;
  final num livePrice;
  final num liveMarketValue;
  final num dayChange;
  final num dayPercent;
  final dynamic historicalFrame;
  final bool isLive;

  const ExpandedHolding({
    required this.holding,
    required this.account,
    required this.livePrice,
    required this.liveMarketValue,
    required this.dayChange,
    required this.dayPercent,
    required this.historicalFrame,
    required this.isLive,
  });
}
