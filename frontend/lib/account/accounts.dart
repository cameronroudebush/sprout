import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/dialog/add_account.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/account/widgets/account_groups.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/user/provider.dart';

/// A widget that displays all accounts
///
/// In the event no accounts are found, it provides a way to add them
class AccountsWidget extends StatelessWidget {
  /// If the account groups should be collapsible
  final bool allowCollapse;
  final ChartRange netWorthPeriod;

  /// If this groups should render in a card
  final bool applyCard;

  const AccountsWidget({super.key, required this.netWorthPeriod, this.allowCollapse = false, this.applyCard = true});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AccountProvider, UserProvider>(
      builder: (context, accountProvider, userProvider, child) {
        final mediaQuery = MediaQuery.of(context);
        if (accountProvider.isLoading || userProvider.isLoading) {
          return SizedBox(
            height: mediaQuery.size.height * .8,
            width: double.infinity,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (accountProvider.linkedAccounts.isEmpty) {
          final content = SizedBox(
            height: mediaQuery.size.height * .2,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget(
                  referenceSize: 1.5,
                  text: "Link an account to get started!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SproutTooltip(
                  message: "Add an account",
                  child: ButtonWidget(
                    text: "Add Account",
                    icon: Icons.add,
                    minSize: mediaQuery.size.width * .2,
                    onPressed: () async {
                      // Open the add account dialog
                      await showDialog(context: context, builder: (_) => AddAccountDialog());
                    },
                  ),
                ),
              ],
            ),
          );
          return applyCard ? SproutCard(child: content) : content;
        }
        return AccountGroupsWidget(
          accounts: accountProvider.linkedAccounts,
          allowCollapse: allowCollapse,
          netWorthPeriod: netWorthPeriod,
          applyCard: applyCard,
        );
      },
    );
  }
}
