import 'package:flutter/material.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/user/model/user_display_info.dart';
import 'package:sprout/user/widgets/info_row.dart';

/// Provides a card to contain settings and other information
class UserInfoCard extends StatelessWidget {
  final List<UserDisplayInfo> info;
  final String name;

  const UserInfoCard({super.key, required this.info, required this.name});

  @override
  Widget build(BuildContext context) {
    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return SproutCard(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 12.0 : 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name.toTitleCase,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const Divider(height: 32.0, thickness: 1.0),
              // Render all info
              ...info.map((x) => UserInfoRow(info: x)).toList(),
            ],
          ),
        ),
      );
    });
  }
}
