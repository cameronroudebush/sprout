import 'package:flutter/material.dart';
import 'package:sprout/core/models/notification.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/layout.dart';

/// A widget that is used to display a [SproutNotification]
class SproutNotificationWidget extends StatelessWidget {
  final SproutNotification notification;

  const SproutNotificationWidget(this.notification, {super.key});

  @override
  Widget build(BuildContext context) {
    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return SproutCard(
        bgColor: notification.bgColor,
        child: Padding(
          padding: EdgeInsetsGeometry.all(12),
          child: InkWell(
            onTap: notification.onClick,
            child: Row(
              spacing: 8,
              children: [
                if (notification.icon != null) Icon(notification.icon, color: notification.color),
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        notification.message,
                        style: TextStyle(color: notification.color, fontSize: isDesktop ? 16 : 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
