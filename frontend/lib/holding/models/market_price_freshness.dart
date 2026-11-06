import 'package:sprout/api/api.dart';
import 'package:sprout/holding/models/expanded_holding.dart';

/// Returns true when a mutual-fund quote cannot be compared with latest
/// regular-market close. PRE/PREPRE ignore pre-market price fields; comparison
/// still requires fund quote timestamp newer than close reference.
bool isMutualFundNavPending(
  ExpandedHolding holding,
  MarketIndexDto? marketReference,
) {
  if (holding.type != MarketIndexDtoTypeEnum.MUTUALFUND) return false;

  const afterRegularSessionStates = {
    MarketIndexDtoMarketStateEnum.CLOSED,
    MarketIndexDtoMarketStateEnum.POST,
    MarketIndexDtoMarketStateEnum.POSTPOST,
    MarketIndexDtoMarketStateEnum.PRE,
    MarketIndexDtoMarketStateEnum.PREPRE,
  };

  if (marketReference == null ||
      marketReference.marketState == MarketIndexDtoMarketStateEnum.REGULAR ||
      !marketReference.hasMarketTimestamp ||
      !holding.hasMarketTimestamp ||
      !afterRegularSessionStates.contains(holding.marketState)) {
    return true;
  }

  final quoteAsOf = DateTime.tryParse(holding.lastUpdated);
  final marketCloseAsOf = DateTime.tryParse(marketReference.lastUpdated);
  return quoteAsOf == null ||
      marketCloseAsOf == null ||
      !quoteAsOf.isAfter(marketCloseAsOf);
}
