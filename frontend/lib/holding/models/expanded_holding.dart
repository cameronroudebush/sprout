import 'package:sprout/api/api.dart';

/// Defines a holding that contains additional information to calculate live day changes as well as additional
///   historical information.
class ExpandedHolding extends MarketIndexDto {
  final Holding holding;
  final Account? account;
  final num livePrice;
  final num liveMarketValue;
  final num dayChange;
  final num dayPercent;
  final dynamic historicalFrame;
  final bool isLive;
  final num totalGain;
  final num totalGainPercent;

  ExpandedHolding({
    required this.holding,
    required this.account,
    required this.livePrice,
    required this.liveMarketValue,
    required this.dayChange,
    required this.dayPercent,
    required this.historicalFrame,
    required this.isLive,
    super.previousClose,
    super.dayLow,
    super.dayHigh,
    super.marketState,
    super.dividendYield,
    required num basePrice,
    required String baseSymbol,
    required String baseName,
    required num baseChange,
    required num baseChangePercent,
    required String baseLastUpdated,
    required this.totalGain,
    required this.totalGainPercent,
  }) : super(
          price: basePrice,
          symbol: baseSymbol,
          name: baseName,
          change: baseChange,
          changePercent: baseChangePercent,
          lastUpdated: baseLastUpdated,
        );
}
