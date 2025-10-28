import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/dialog/add_account.dart';
import 'package:sprout/account/widgets/account_groups.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';

/// The main accounts display that contains the chart along side the actual accounts list
class AccountsWidget extends StatefulWidget {
  /// If the account groups should be collapsible
  final bool allowCollapse;
  final ChartRangeEnum netWorthPeriod;

  /// If provided, allows a specific account type to be loaded only
  final AccountTypeEnum? accountType;

  /// If this groups should render in a card
  final bool applyCard;

  /// If group titles should be shown for each account group
  final bool showGroupTitles;

  const AccountsWidget({
    super.key,
    required this.netWorthPeriod,
    this.allowCollapse = false,
    this.applyCard = true,
    this.accountType,
    this.showGroupTitles = true,
  });

  @override
  State<AccountsWidget> createState() => _AccountsWidgetState();
}

class _AccountsWidgetState extends State<AccountsWidget> {
  final accountProvider = ServiceLocator.get<AccountProvider>();

  @override
  void initState() {
    super.initState();
    accountProvider.populateLinkedAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        final mediaQuery = MediaQuery.of(context);
        if (accountProvider.isLoading) {
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
          return widget.applyCard ? SproutCard(child: content) : content;
        }

        final accounts = widget.accountType == null
            ? accountProvider.linkedAccounts
            : accountProvider.linkedAccounts.where((element) => element.type == widget.accountType).toList();

        return AccountGroupsWidget(
          accounts: accounts,
          allowCollapse: widget.allowCollapse,
          netWorthPeriod: widget.netWorthPeriod,
          applyCard: widget.applyCard,
          showGroupTitles: widget.showGroupTitles,
          onAccountClick: (account) {
            SproutNavigator.redirect("account", queryParameters: {"acc": account.id});
          },
        );
      },
    );
  }
}
