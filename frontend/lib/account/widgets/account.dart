import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/dialog/account_delete.dart';
import 'package:sprout/account/dialog/account_error.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/account/widgets/account_logo.dart';
import 'package:sprout/account/widgets/account_sub_type.dart';
import 'package:sprout/account/widgets/institution_error.dart';
import 'package:sprout/charts/line_chart.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/scroll.dart';
import 'package:sprout/core/widgets/tabs.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/holding/provider.dart';
import 'package:sprout/holding/widgets/account.dart';
import 'package:sprout/net-worth/provider.dart';
import 'package:sprout/net-worth/widgets/net_worth_text.dart';
import 'package:sprout/net-worth/widgets/range_selector.dart';
import 'package:sprout/transaction/overview.dart';
import 'package:sprout/user/provider.dart';

/// A page that displays information about the given account
class AccountWidget extends StatelessWidget {
  /// The account we must have data from
  final Account account;

  const AccountWidget(this.account, {super.key});

  /// Returns the tab content for the overview display
  Widget _buildOverviewContent(BuildContext context, NetWorthProvider netWorthProvider, UserProvider userProvider) {
    final chartRange = userProvider.userDefaultChartRange;
    final data = netWorthProvider.historicalAccountData?.firstWhereOrNull((e) => e.connectedId == account.id);
    final accountDataForRange = data?.getValueByFrame(chartRange);
    return SproutScrollView(
      padding: EdgeInsets.zero,
      child: SproutCard(
        child: Padding(
          padding: EdgeInsetsGeometry.all(12),
          child: accountDataForRange == null
              ? SizedBox(height: 250, child: TextWidget(text: "Failed to locate any account history"))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 24,
                  children: [
                    NetWorthTextWidget(
                      chartRange,
                      account.balance,
                      accountDataForRange.percentChange,
                      accountDataForRange.valueChange,
                      title: "Account Value",
                    ),
                    SproutLineChart(
                      data: accountDataForRange.history,
                      chartRange: chartRange,
                      formatValue: (value) => getFormattedCurrency(value),
                      showGrid: true,
                      showXAxis: true,
                      height: 150,
                    ),
                    ChartRangeSelector(
                      selectedChartRange: chartRange,
                      onRangeSelected: (value) {
                        userProvider.updateChartRange(value);
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Returns the tab content for the transactions display
  Widget _buildTransactionContent(BuildContext context) {
    return Column(children: [TransactionsOverview(account: account)]);
  }

  /// Returns the tab content for the holdings display
  Widget _buildHoldingsContent(BuildContext context, HoldingProvider holdingProvider) {
    final holdings = holdingProvider.holdings.where((h) => h.account.id == account.id).toList();
    return Column(children: [HoldingAccount(account, holdings, displayAccountHeader: false)]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<UserProvider, AccountProvider, NetWorthProvider, HoldingProvider>(
      builder: (context, userProvider, accountProvider, netWorthProvider, holdingProvider, child) {
        final List<String> tabs = ["Overview", "Transactions"];
        final List<Widget> tabContents = [
          _buildOverviewContent(context, netWorthProvider, userProvider),
          _buildTransactionContent(context),
        ];

        if (account.type == "investment") {
          tabs.add("Holdings");
          tabContents.add(_buildHoldingsContent(context, holdingProvider));
        }

        return Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppTheme.maxDesktopSize),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Top Bar of Account info
                SproutCard(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(12),
                    child: Column(
                      spacing: 12,
                      children: [
                        // Account information
                        Row(
                          spacing: 24,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Logo
                            AccountLogoWidget(account),
                            // Account names
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(text: account.name, referenceSize: 1.5),
                                TextWidget(
                                  text: account.institution.name,
                                  referenceSize: 1,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            InstitutionError(institution: account.institution),
                          ],
                        ),
                        const Divider(height: 1),
                        // End buttons
                        Wrap(
                          spacing: 24,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            // Account sub type
                            SizedBox(
                              width: 240,
                              child: AccountSubTypeSelect(
                                account,
                                onChanged: (newSubType) {
                                  account.subType = newSubType;
                                  accountProvider.edit(account);
                                },
                              ),
                            ),
                            // Institution error fix
                            if (account.institution.hasError)
                              SproutTooltip(
                                message: "Opens a dialog to fix this account.",
                                child: FilledButton(
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (_) => AccountErrorDialog(account: account),
                                    );
                                  },
                                  child: TextWidget(text: "Fix Account"),
                                ),
                              ),
                            // Delete account
                            SproutTooltip(
                              message: "Opens a dialog to delete this account.",
                              child: FilledButton(
                                style: AppTheme.errorButton,
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (_) => AccountDeleteDialog(account: account),
                                  );
                                },
                                child: TextWidget(text: "Delete"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Render the tabs for the different content views
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ScrollableTabsWidget(tabs, tabContents, initialIndex: 0);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
