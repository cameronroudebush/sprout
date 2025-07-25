import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/account/provider.dart';
import 'package:sprout/account/widgets/account_groups.dart';

class AccountOverviewPage extends StatelessWidget {
  const AccountOverviewPage({super.key});

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
        }
        return AccountGroupsWidget(accounts: accountProvider.linkedAccounts);
      },
    );
  }
}
