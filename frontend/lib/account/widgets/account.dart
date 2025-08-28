import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/dialog/account_delete.dart';
import 'package:sprout/account/dialog/account_error.dart';
import 'package:sprout/account/models/account.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/account/widgets/account_logo.dart';
import 'package:sprout/account/widgets/institution_error.dart';
import 'package:sprout/charts/line_chart.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/net-worth/provider.dart';
import 'package:sprout/net-worth/widgets/net_worth_text.dart';
import 'package:sprout/net-worth/widgets/range_selector.dart';
import 'package:sprout/user/provider.dart';

/// A page that displays information about the given account
class AccountWidget extends StatelessWidget {
  /// The account we must have data from
  final Account account;

  const AccountWidget(this.account, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, AccountProvider, NetWorthProvider>(
      builder: (context, userProvider, accountProvider, netWorthProvider, child) {
        final chartRange = userProvider.userDefaultChartRange;
        final data = netWorthProvider.historicalAccountData?.firstWhereOrNull((e) => e.connectedId == account.id);
        final accountDataForRange = data?.getValueByFrame(chartRange);
        return Column(
          children: [
            // Top Bar
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
                    Row(
                      spacing: 24,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
            // Balance card
            SproutCard(
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
            // TODO: Account specific transactions
          ],
        );
      },
    );
  }
}
