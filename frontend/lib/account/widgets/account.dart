import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/dialog/account_delete.dart';
import 'package:sprout/account/dialog/account_error.dart';
import 'package:sprout/account/models/account.dart'; // Assuming you have this model
import 'package:sprout/account/widgets/account_change.dart';
import 'package:sprout/account/widgets/account_logo.dart';
import 'package:sprout/account/widgets/institution_error.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/net-worth/models/entity.history.dart';
import 'package:sprout/net-worth/provider.dart';
import 'package:sprout/user/provider.dart';

/// A widget used to display the given account
class AccountWidget extends StatelessWidget {
  /// On click of this account. Overrides the expansion behavior.
  final VoidCallback? onClick;
  final bool allowClick;
  final Account account;
  final ChartRange netWorthPeriod;
  // If this account should display a "selected" indicator
  final bool isSelected;

  /// If stats should be displayed (percentage changes etc)
  final bool displayStats;

  /// If we should display the total values
  final bool displayTotals;

  /// If we should show the percentage change of this netWorthPeriod
  final bool showPercentage;

  /// If we want to show the netWorthPeriod string in the percentage change
  final bool showPeriod;

  const AccountWidget({
    super.key,
    required this.account,
    required this.netWorthPeriod,
    required this.displayStats,
    required this.displayTotals,
    this.onClick,
    this.isSelected = false,
    this.allowClick = true,
    this.showPercentage = false,
    this.showPeriod = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer3<ConfigProvider, NetWorthProvider, UserProvider>(
      builder: (context, configProvider, netWorthProvider, userProvider, child) {
        final theme = Theme.of(context);
        return InkWell(
          onTap: allowClick && onClick != null
              ? () {
                  onClick!();
                }
              : null,
          child: IgnorePointer(
            ignoring: onClick != null,
            child: Theme(
              data: theme.copyWith(
                // Remove trailing and leading dividers when expansion tile is open
                dividerColor: Colors.transparent,
                disabledColor: theme.textTheme.titleMedium?.color,
              ),
              child: ExpansionTile(
                enabled: allowClick,
                title: _getAccountHeader(context, account, theme, netWorthProvider, userProvider),
                showTrailingIcon: false,
                children: [
                  // Inner details
                  Padding(
                    padding: EdgeInsetsGeometry.directional(start: 24, top: 12, bottom: 12, end: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 12,
                      children: [
                        // Account error fixing
                        if (account.institution.hasError)
                          Expanded(
                            child: SproutTooltip(
                              message: "Opens a page to fix this account.",
                              child: ButtonWidget(
                                text: "Fix Account",
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (_) => AccountErrorDialog(account: account),
                                  );
                                },
                              ),
                            ),
                          ),
                        Expanded(
                          child: ButtonWidget(
                            text: "Delete",
                            color: theme.colorScheme.onError,
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (_) => AccountDeleteDialog(account: account),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Gets the account header for the expansion panel
  Widget _getAccountHeader(
    BuildContext context,
    Account account,
    ThemeData theme,
    NetWorthProvider netWorthProvider,
    UserProvider userProvider,
  ) {
    final mediaQuery = MediaQuery.of(context).size;
    // Days changed depending on the configuration
    EntityHistoryDataPoint? dayChange = netWorthProvider.historicalAccountData
        ?.firstWhereOrNull((element) => element.connectedId == account.id)
        ?.getValueByFrame(netWorthPeriod);

    return Padding(
      padding: EdgeInsetsGeometry.directional(start: 0, end: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 12,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      // Only show on large enough screens
                      if (isSelected && mediaQuery.width > 640)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, right: 16),
                          child: Icon(Icons.check_circle, color: theme.colorScheme.secondary, size: 24.0),
                        ),
                      AccountLogoWidget(account),
                      SizedBox(width: 12),
                      // Print details about the account, start of row
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            TextWidget(
                              text: account.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.start,
                            ),
                            TextWidget(
                              text: account.institution.name.toTitleCase,
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
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 4,
                    children: [
                      InstitutionError(institution: account.institution),
                      Column(
                        spacing: 12,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Account balance
                          if (displayTotals) TextWidget(text: getFormattedCurrency(account.balance)),
                          // If our day change is null, we don't have enough data to come up with a calculation
                          if (dayChange != null && displayStats)
                            AccountChangeWidget(
                              percentageChange: dayChange.percentChange,
                              totalChange: account.isNegativeNetWorth
                                  ? dayChange.valueChange * -1
                                  : dayChange.valueChange,
                              showPercentage: showPercentage,
                              netWorthPeriod: showPeriod ? netWorthPeriod : null,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
