import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/model/account_extensions.dart';
import 'package:sprout/account/widgets/account_change.dart';
import 'package:sprout/account/widgets/account_logo.dart';
import 'package:sprout/account/widgets/account_sub_type.dart';
import 'package:sprout/account/widgets/institution_error.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/net-worth/model/entity_history_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/user/user_provider.dart';

/// A widget used to display the given account and information in a row
class AccountRowWidget extends StatelessWidget {
  /// On click of this account. Overrides the expansion behavior.
  final VoidCallback? onClick;
  final bool allowClick;
  final Account account;
  final ChartRangeEnum netWorthPeriod;
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

  /// If we should apply the green/red color to the total
  final bool applyColorToTotal;

  /// If we should display the selectable subType of the account
  final bool displaySubType;

  const AccountRowWidget({
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
    this.applyColorToTotal = false,
    this.displaySubType = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= SproutLayoutBuilder.desktopBreakpoint;
    return Consumer3<ConfigProvider, NetWorthProvider, UserProvider>(
      builder: (context, configProvider, netWorthProvider, userProvider, child) {
        final theme = Theme.of(context);
        return InkWell(
          onTap: allowClick && onClick != null
              ? () {
                  onClick!();
                }
              : null,
          child: Theme(
            data: theme.copyWith(
              // Remove trailing and leading dividers when expansion tile is open
              dividerColor: Colors.transparent,
              disabledColor: theme.textTheme.titleMedium?.color,
            ),
            child: Padding(
              padding: EdgeInsetsGeometry.all(12),
              child: _getAccountHeader(context, account, theme, netWorthProvider, userProvider, isDesktop),
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
    bool isDesktop,
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
                  flex: 3,
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
                            Text(
                              account.name,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: isDesktop ? 16 : 12),
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              account.institution.name.toTitleCase,
                              style: TextStyle(color: Colors.grey, fontSize: isDesktop ? 14 : 10),
                              textAlign: TextAlign.start,
                            ),

                            // Sub type selection
                            if (displaySubType) AccountSubTypeSelect(account),
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
                          if (displayTotals)
                            Text(
                              getFormattedCurrency(account.balance),
                              style: TextStyle(
                                color: applyColorToTotal ? getBalanceColor(account.balance, theme) : null,
                              ),
                            ),
                          // If our day change is null, we don't have enough data to come up with a calculation
                          if (dayChange != null && displayStats)
                            AccountChangeWidget(
                              percentageChange: account.isNegativeNetWorth && dayChange.percentChange != null
                                  ? dayChange.percentChange! * -1
                                  : dayChange.valueChange,
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
