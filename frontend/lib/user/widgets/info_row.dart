import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/user/model/user_display_info.dart';
import 'package:sprout/user/provider.dart';

/// Provides a row of info to display in the card structure of the user page
class UserInfoRow extends StatelessWidget {
  final UserDisplayInfo info;

  const UserInfoRow({super.key, required this.info});

  /// Renders the main content within the page
  Widget _renderMainContent(BuildContext context) {
    return Column(
      spacing: 4,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          referenceSize: 1.2,
          text: info.title,
          style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        if (info.hint != null)
          Padding(
            padding: EdgeInsetsGeometry.directional(start: 12, end: 12),
            child: TextWidget(
              referenceSize: .8,
              text: info.hint!,
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.start,
            ),
          ),
        if (info.value != null)
          Padding(
            padding: EdgeInsetsGeometry.directional(start: 12, end: 12),
            child: TextWidget(referenceSize: 1, text: info.value!, style: TextStyle()),
          ),
        if (info.child != null) info.child!,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final mainContent = _renderMainContent(context);
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (info.icon != null) ...[
              Icon(info.icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 12.0),
            ],
            Expanded(
              child: info.settingValue != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: mainContent),
                        if (info.settingType == "bool")
                          Switch(
                            value: info.settingValue,
                            onChanged: (value) {
                              userProvider.currentUserConfig!.privateMode = value;
                              userProvider.updateConfig(userProvider.currentUserConfig!);
                            },
                          ),
                      ],
                    )
                  : mainContent,
            ),
          ],
        );
      },
    );
  }
}

// return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (icon != null) ...[
//           Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
//           const SizedBox(width: 12.0),
//         ],
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextWidget(
//                 referenceSize: 1.2,
//                 text: label,
//                 style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant),
//               ),
//               const SizedBox(height: 4.0),
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: display),
//             ],
//           ),
//         ),
//       ],
//     );
