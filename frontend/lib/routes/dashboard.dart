import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/widgets/dashboard_accounts_card.dart';
import 'package:sprout/holding/widgets/market_indices_bar.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/net-worth/widgets/net_worth_card.dart';
import 'package:sprout/notification/widgets/home_notifications.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/transaction/widgets/dashboard_recent_transactions.dart';

/// The initial landing page when the user logs in to the app
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netWorth = ref.watch(totalNetWorthProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Important notifications that the user needs to know
          const HomeNotificationsWidget(),
          // Major indices for the current market
          const MajorIndicesBarWidget(),
          // Net worth chart
          SproutCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: NetWorthDisplay(
                title: "Net Worth",
                historyData: netWorth.whenData((data) => data?.history),
                timelineData: netWorth.whenData((data) => data?.timeline),
                currentValue: netWorth.whenData((data) => data?.value),
              ),
            ),
          ),
          // Account overview
          const DashboardAccountsCard(),
          // Recent transactions
          const DashboardRecentTransactionsCard(),
        ],
      ),
    );
  }
}
