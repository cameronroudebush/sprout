import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/widgets/dashboard_accounts_card.dart';
import 'package:sprout/category/widgets/category_pie_chart.dart';
import 'package:sprout/net-worth/widgets/user_net_worth.dart';
import 'package:sprout/notification/widgets/home_notifications.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/pie_chart.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/transaction/widgets/dashboard_recent_transactions.dart';
import 'package:sprout/transaction/widgets/subscriptions_calendar.dart';

/// The initial landing page when the user logs in to the app
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: SproutLayoutBuilder(
        (isDesktop, context, constraints) {
          if (isDesktop) {
            return SproutRouteWrapper(
              maxWidth: 1280,
              child: _buildDesktop(ref),
            );
          } else {
            return SproutRouteWrapper(child: _buildMobile(ref));
          }
        },
      ),
    );
  }

  /// Desktop gets a robust 2-column masonry display utilizing flex factors
  Widget _buildDesktop(WidgetRef ref) {
    const double gutter = 4.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeNotificationsWidget(),
        const SizedBox(height: gutter),

        // Top section: Net Worth
        const SproutCard(child: Padding(padding: EdgeInsets.all(12), child: UserNetWorthWidget())),
        const SizedBox(height: gutter),

        // Middle section
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: DashboardAccountsCard()),
            const SizedBox(width: gutter),
            Expanded(
                flex: 1,
                child: CategoryPieChart(
                  DateTime.now(),
                  legendPosition: PieLegendPosition.bottom,
                  topN: 10,
                  height: 245,
                )),
            const SizedBox(width: gutter),
            Expanded(flex: 1, child: SubscriptionCalendarWidget(title: "Subscriptions", showDetails: false)),
          ],
        ),
        const SizedBox(height: gutter),

        // Bottom section
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: DashboardRecentTransactionsCard(count: 7)),
          ],
        ),
      ],
    );
  }

  /// Mobile just renders vertically
  Widget _buildMobile(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Important notifications that the user needs to know
        const HomeNotificationsWidget(),
        // Net worth chart
        SproutCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: UserNetWorthWidget(),
          ),
        ),
        // Account overview
        const DashboardAccountsCard(),
        // Recent transactions
        const DashboardRecentTransactionsCard(),
      ],
    );
  }
}
