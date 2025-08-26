import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/models/account.dart'; // Assuming you have this model
import 'package:sprout/account/widgets/account_change.dart';
import 'package:sprout/account/widgets/account_row.dart';
import 'package:sprout/account/widgets/institution_error.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/net-worth/models/entity.history.dart';
import 'package:sprout/net-worth/provider.dart';

/// When we calculate data for a group, we'll return this type
class GroupCalculatedData {
  final double percentageChange;
  final double totalBalance;
  final double totalChange;
  GroupCalculatedData({required this.percentageChange, required this.totalBalance, required this.totalChange});
}

/// A widget used to display a grouping of accounts for a specific type
class AccountGroupWidget extends StatelessWidget {
  final List<Account> accounts;
  final String type;
  final ChartRange netWorthPeriod;
  final double totalNetWorth;
  final void Function(Account)? onAccountClick;
  final Set<Account>? selectedAccounts;

  /// If this group should render in a card
  final bool applyCard;

  /// If stats should be displayed (percentage changes etc)
  final bool displayStats;

  /// If we should display the total values
  final bool displayTotals;

  /// If the group should be collapsible
  final bool allowCollapse;

  /// If we should render the title for this section with more info and total percentages
  final bool showTitle;

  const AccountGroupWidget({
    super.key,
    required this.netWorthPeriod,
    required this.accounts,
    required this.type,
    required this.totalNetWorth,
    this.onAccountClick,
    required this.displayStats,
    required this.displayTotals,
    this.selectedAccounts,
    required this.allowCollapse,
    required this.applyCard,
    this.showTitle = true,
  });

  /// Calculates useful content per group of given accounts with historical data and returns it
  static GroupCalculatedData calculate(List<EntityHistory>? historical, List<Account> accounts, ChartRange chartRange) {
    final totalBalance = accounts.fold(0.0, (sum, account) => sum + account.balance);
    double groupAmountChange = 0;
    // Filter the historical data once.
    final filteredGroupData = historical?.where(
      (element) => accounts.any((account) => account.id == element.connectedId),
    );

    // Use a for-in loop to iterate through the filtered data and accumulate sums.
    if (filteredGroupData != null) {
      for (final element in filteredGroupData) {
        final valueByFrame = element.getValueByFrame(chartRange);
        // TODO This seems to be off
        groupAmountChange += valueByFrame.valueChange;
      }
    }
    final groupPercentChange = groupAmountChange == totalBalance
        ? double.infinity
        : (groupAmountChange / totalBalance) * 100;
    return GroupCalculatedData(
      percentageChange: groupPercentChange,
      totalBalance: totalBalance,
      totalChange: groupAmountChange,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConfigProvider, NetWorthProvider>(
      builder: (context, configProvider, netWorthProvider, child) {
        final groupCalc = AccountGroupWidget.calculate(
          netWorthProvider.historicalAccountData,
          accounts,
          netWorthPeriod,
        );
        double groupAmountChange = groupCalc.totalChange;
        final groupPercentChange = groupCalc.percentageChange;
        final totalBalance = groupCalc.totalBalance;

        /// The percent of total net worth
        final percentOfType = (totalBalance / totalNetWorth) * 100;
        final theme = Theme.of(context);
        final balanceColor = getBalanceColor(totalBalance, theme);

        final accountWithInstitutionError = accounts.firstWhereOrNull((x) => x.institution.hasError);

        // Simplify the types and perform some extra handling on debts
        String simpleType;
        if (type == "loan" || type == "credit") {
          simpleType = "debts";
          groupAmountChange *= -1;
        } else {
          simpleType = "assets";
        }

        /// A cleaned up type name for display
        String adjustedType = formatAccountType(type.toLowerCase());

        final element = Theme(
          data: theme.copyWith(
            // Remove trailing and leading dividers when expansion tile is open
            dividerColor: Colors.transparent,
            disabledColor: theme.textTheme.titleMedium?.color,
            expansionTileTheme: ExpansionTileThemeData(backgroundColor: theme.cardTheme.color),
          ),
          child: ExpansionTile(
            enabled: allowCollapse,
            initiallyExpanded: !allowCollapse,
            showTrailingIcon: false,
            minTileHeight: !showTitle ? 0 : null,
            tilePadding: !showTitle ? EdgeInsets.zero : null,
            title: !showTitle
                ? SizedBox.shrink()
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          spacing: 4,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              referenceSize: 1.25,
                              text: adjustedType,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (displayStats)
                              AccountChangeWidget(
                                percentageChange: groupPercentChange,
                                totalChange: groupAmountChange,
                                mainAxisAlignment: MainAxisAlignment.start,
                                netWorthPeriod: netWorthPeriod,
                                useExtendedPeriodString: true,
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 10,
                          children: [
                            InstitutionError(
                              institution: accountWithInstitutionError?.institution,
                              overrideMessage: "An account within this group contains an error",
                            ),
                            // Asset information
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 4,
                              children: [
                                // Group balance
                                if (displayTotals)
                                  TextWidget(
                                    referenceSize: 1.15,
                                    text: getFormattedCurrency(totalBalance),
                                    style: TextStyle(fontWeight: FontWeight.bold, color: balanceColor),
                                  ),
                                // Percent of total net worth
                                if (displayStats)
                                  TextWidget(
                                    referenceSize: .9,
                                    text: "${formatPercentage(percentOfType)} of $simpleType",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            children: [
              const Divider(height: 1),
              ...accounts.expand((account) {
                final isSelected = selectedAccounts?.contains(account) ?? false;
                final lastAccountIsSelected =
                    accounts.first != account &&
                    (selectedAccounts?.contains(accounts[accounts.indexOf(account) - 1]) ?? false);

                // Determine border for selection
                BoxBorder? border;
                if (isSelected == true) {
                  final width = 3.0;
                  final color = theme.colorScheme.secondary;
                  border = Border(
                    top: accounts.first == account || !lastAccountIsSelected
                        ? BorderSide(width: width, color: color)
                        : BorderSide.none,
                    left: BorderSide(width: width, color: color),
                    right: BorderSide(width: width, color: color),
                    bottom: BorderSide(width: width, color: color),
                  );
                }

                return [
                  Container(
                    decoration: BoxDecoration(
                      border: border,
                      borderRadius: accounts.last == account
                          ? BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))
                          : null,
                    ),
                    child: Column(
                      children: [
                        AccountRowWidget(
                          account: account,
                          netWorthPeriod: netWorthPeriod,
                          displayTotals: displayTotals,
                          displayStats: displayStats,
                          onClick: onAccountClick == null ? null : () => onAccountClick!(account),
                          isSelected: isSelected,
                        ),
                        if (account != accounts.last) const Divider(height: 1),
                      ],
                    ),
                  ),
                ];
              }),
            ],
          ),
        );

        return applyCard ? SproutCard(child: element) : element;
      },
    );
  }
}
