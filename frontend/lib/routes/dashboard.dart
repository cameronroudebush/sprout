import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/widgets/dashboard_accounts_card.dart';
import 'package:sprout/cash-flow/widgets/spending_calendar.dart';
import 'package:sprout/cash-flow/widgets/spending_compare.dart';
import 'package:sprout/category/widgets/category_pie_chart.dart';
import 'package:sprout/net-worth/widgets/user_net_worth.dart';
import 'package:sprout/notification/widgets/home_notifications.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/header.dart';
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
              size: SproutRouteSize.large,
              child: _buildDesktop(context, ref),
            );
          } else {
            return SproutRouteWrapper(child: _buildMobile(ref));
          }
        },
      ),
    );
  }

  /// Desktop gets a robust 2-column masonry display utilizing flex factors
  Widget _buildDesktop(BuildContext context, WidgetRef ref) {
    final topCategoryCount = 10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeNotificationsWidget(),
        SizedBox(
          height: 300,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 2,
                child: const SproutCard(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: UserNetWorthWidget(),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: const SproutCard(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: SpendingCompareChart(),
                  ),
                ),
              ),
            ],
          ),
        ),
        ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 425),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: DashboardAccountsCard(),
                    ),
                    // We leave a blank space for the pie chart to sit over
                    Expanded(flex: 1, child: const SizedBox.shrink()),
                  ],
                ),
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: const SizedBox.shrink()),
                      Expanded(
                        flex: 1,
                        child: SproutCard(
                          child: Center(
                            child: CategoryPieChart(
                              DateTime.now(),
                              legendPosition: PieLegendPosition.bottom,
                              topN: topCategoryCount,
                              header: ChartHeader(
                                title: "Top $topCategoryCount Purchase Categories",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: SpendingCalendarWidget()),
            Expanded(flex: 1, child: DashboardRecentTransactionsCard(count: 9)),
            Expanded(
                child: SubscriptionCalendarWidget(
              title: "Subscriptions",
              showDetails: false,
              iconSize: 14,
            )),
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
        SizedBox(
          height: 200,
          child: UserNetWorthWidget(mobile: true),
        ),
        // Account overview
        const DashboardAccountsCard(),
        // Recent transactions
        const DashboardRecentTransactionsCard(),
      ],
    );
  }
}
