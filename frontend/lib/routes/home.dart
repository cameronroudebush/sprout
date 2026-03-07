import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/holding/widgets/market_indices_bar.dart';
import 'package:sprout/net-worth/widgets/net_worth_card.dart';
import 'package:sprout/notification/widgets/home_notifications.dart';
import 'package:sprout/shared/widgets/card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeNotificationsWidget(),

          const MajorIndicesBarWidget(),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 1000;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 3, child: NetWorthCard()),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: const [
                          // In the future, these will be your specific grid components
                          SproutCard(child: Text("Account Overview Grid")),
                          SproutCard(child: Text("Recent Transactions")),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: const [
                  NetWorthCard(),
                  SproutCard(child: Text("Account Overview Grid")),
                  SproutCard(child: Text("Recent Transactions")),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
