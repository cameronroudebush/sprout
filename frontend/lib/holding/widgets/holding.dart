import 'package:flutter/material.dart';
import 'package:sprout/account/widgets/account_change.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/holding/widgets/holding_logo.dart';

/// Renders a single holding
// ignore: must_be_immutable
class HoldingWidget extends StatelessWidget {
  final Holding holding;
  bool isSelected;
  Function(Holding holding)? onClick;

  HoldingWidget({super.key, required this.holding, this.isSelected = false, this.onClick});

  @override
  Widget build(BuildContext context) {
    final costBasisTotalChange = holding.marketValue - holding.costBasis;
    final costBasisPercentChange = (holding.marketValue - holding.costBasis) / holding.costBasis * 100;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final renderSymbol = true;
        final renderDescription = false;

        final statsContent = _buildContent(isMobile, costBasisTotalChange, costBasisPercentChange);

        return InkWell(
          onTap: () {
            if (onClick != null) onClick!(holding);
          },
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 4),
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
                            // Render logo
                            HoldingLogoWidget(holding),
                            // Print details about the holding
                            // ignore: dead_code
                            if (renderSymbol || renderDescription)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8,
                                  children: [
                                    if (renderSymbol)
                                      TextWidget(
                                        text: holding.symbol,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.start,
                                      ),
                                    if (renderDescription)
                                      // ignore: dead_code
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

  Widget _buildContent(bool isMobile, num costBasisTotalChange, double costBasisPercentChange) {
    final content = [
      // Amount of shares
      _buildColumnOfContent("Shares", holding.shares.toStringAsFixed(2), row: isMobile),
      const Divider(height: 1),
      // Cost basis
      _buildColumnOfContent(
        "Cost Basis",
        getFormattedCurrency(holding.costBasis),
        description: "The original total cost for this asset",
        row: isMobile,
      ),
      const Divider(height: 1),
      // Current Value
      _buildColumnOfContent(
        "Market Value",
        getFormattedCurrency(holding.marketValue),
        description: "The current value of this asset",
        row: isMobile,
      ),
      const Divider(height: 1),
      // Total value change
      _buildColumnOfContent(
        "Total Change",
        "",
        description: "This is the total gain/loss calculated from cost basis and market value",
        child: AccountChangeWidget(totalChange: costBasisTotalChange, percentageChange: costBasisPercentChange),
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

  /// Builds a column of a specific type of content related to the stock
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
            style: TextStyle(color: Colors.grey),
          ),
          if (description != null)
            SproutTooltip(
              message: description,
              child: Icon(Icons.info, size: 16, color: Colors.grey),
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
