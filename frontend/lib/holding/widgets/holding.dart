import 'package:flutter/material.dart';
import 'package:sprout/account/widgets/account_change.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/holding/models/holding.dart';
import 'package:sprout/holding/widgets/holding_logo.dart';

/// Renders a single holding
class HoldingWidget extends StatelessWidget {
  final Holding holding;

  const HoldingWidget({super.key, required this.holding});

  @override
  Widget build(BuildContext context) {
    final costBasisTotalChange = holding.marketValue - holding.costBasis;
    final costBasisPercentChange = (holding.marketValue - holding.costBasis) / holding.costBasis * 100;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            children: [
              Row(
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
                          flex: 1,
                          child: Row(
                            spacing: 12,
                            children: [
                              // Render logo
                              HoldingLogoWidget(holding),
                              // Print details about the holding
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8,
                                  children: [
                                    TextWidget(
                                      text: holding.symbol,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.start,
                                    ),
                                    TextWidget(
                                      text: holding.description,
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Print details at the end of the row
                        if (!isMobile)
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: isMobile
                                      ? SizedBox.shrink()
                                      : _buildContent(costBasisTotalChange, costBasisPercentChange),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              isMobile ? _buildContent(costBasisTotalChange, costBasisPercentChange) : SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(double costBasisTotalChange, double costBasisPercentChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Amount of shares
        _buildColumnOfContent("Number of Shares", holding.shares.toStringAsFixed(2)),
        // Cost basis
        _buildColumnOfContent(
          "Cost Basis",
          getFormattedCurrency(holding.costBasis),
          description: "The original total cost for this asset",
        ),
        // Current Value
        _buildColumnOfContent(
          "Market Value",
          getFormattedCurrency(holding.marketValue),
          child: AccountChangeWidget(totalChange: costBasisTotalChange, percentageChange: costBasisPercentChange),
          alignment: CrossAxisAlignment.end,
        ),
      ],
    );
  }

  /// Builds a column of a specific type of content related to the stock
  Widget _buildColumnOfContent(
    String text,
    dynamic displayText, {
    String? description,
    Widget? child,
    CrossAxisAlignment alignment = CrossAxisAlignment.center,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      spacing: 4,
      children: [
        Row(
          spacing: 4,
          children: [
            TextWidget(
              text: text,
              referenceSize: 0.9,
              style: TextStyle(color: Colors.grey),
            ),
            if (description != null)
              SproutTooltip(
                message: description,
                child: Icon(Icons.info, size: 16, color: Colors.grey),
              ),
          ],
        ),
        TextWidget(text: displayText),
        if (child != null) child,
      ],
    );
  }
}
