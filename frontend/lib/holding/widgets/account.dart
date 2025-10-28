import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_row.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/holding/widgets/holding.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';

/// Renders a holding display for a specific account
class HoldingAccount extends StatelessWidget {
  /// The account these holdings go to
  final Account account;

  /// The holdings list to render
  final List<Holding> holdings;

  /// If we should render the account header info at the top of the bar. Else renders "Holdings".
  final bool displayAccountHeader;

  /// A selected holding if we have one
  final Holding? selectedHolding;

  /// A callback to fire when a holding is clicked
  final Function(Holding holding)? onHoldingClick;

  const HoldingAccount(
    this.account,
    this.holdings, {
    super.key,
    this.displayAccountHeader = true,
    this.selectedHolding,
    this.onHoldingClick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer4<HoldingProvider, AccountProvider, ConfigProvider, NetWorthProvider>(
      builder: (context, holdingProvider, accountProvider, configProvider, netWorthProvider, child) {
        final mediaQuery = MediaQuery.of(context).size;

        // Loading/no holdings indicator
        if (holdingProvider.isLoading || holdings.isEmpty) {
          return SizedBox(
            height: mediaQuery.height * .7,
            child: Center(
              child: holdingProvider.isLoading
                  ? CircularProgressIndicator()
                  : TextWidget(
                      referenceSize: 2,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      text: 'No holdings found',
                    ),
            ),
          );
        }

        return SproutCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 0,
            children: [
              // Account Row
              if (displayAccountHeader)
                AccountRowWidget(
                  account: account,
                  netWorthPeriod: ChartRangeEnum.oneDay,
                  displayStats: true,
                  displayTotals: true,
                  allowClick: false,
                  showPercentage: true,
                  showPeriod: true,
                ),
              if (!displayAccountHeader)
                Padding(
                  padding: EdgeInsetsGeometry.directional(start: 12, top: 4, bottom: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        referenceSize: 1.5,
                        text: "Holdings",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              const Divider(height: 1),
              // Holdings
              holdings.isEmpty
                  ? TextWidget(text: "No holdings available")
                  : Column(
                      children: holdings.map((holding) {
                        final isSelected = selectedHolding == holding;
                        final lastIsSelected =
                            holdings.first != holding && (selectedHolding == holdings[holdings.indexOf(holding) - 1]);

                        // Determine border for selection
                        BoxBorder? border;
                        if (isSelected == true) {
                          final width = 3.0;
                          final color = theme.colorScheme.secondary;
                          border = Border(
                            top: holdings.first == holding || !lastIsSelected
                                ? BorderSide(width: width, color: color)
                                : BorderSide.none,
                            left: BorderSide(width: width, color: color),
                            right: BorderSide(width: width, color: color),
                            bottom: BorderSide(width: width, color: color),
                          );
                        }

                        return Container(
                          decoration: BoxDecoration(
                            border: border,
                            borderRadius: holdings.last == holding
                                ? BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))
                                : null,
                          ),
                          child: Column(
                            children: [
                              HoldingWidget(
                                holding: holding,
                                isSelected: isSelected,
                                onClick: (holding) {
                                  if (onHoldingClick != null) onHoldingClick!(holding);
                                },
                              ),
                              if (holdings.last != holding) const Divider(height: 1),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        );
      },
    );
  }
}
