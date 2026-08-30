import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/notification/widgets/notification_bell.dart';
import 'package:sprout/routes/settings.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/routes/util/mobile_more_sheet.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/models/extensions/string_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';

/// A widget that displays the header bar for desktop
class SproutDesktopHeader extends ConsumerWidget {
  const SproutDesktopHeader({super.key});

  /// Returns the text to display on the header
  String _getText(WidgetRef ref) {
    final currentPath = ref.watch(currentRouteProvider);
    final user = ref.watch(authProvider).value;

    if (currentPath == "/") {
      final greeting = SproutMoreSheet.getGreeting();
      return "$greeting ${user?.username}";
    }

    final pathSegments = Uri.parse(currentPath).pathSegments;
    if (pathSegments.length == 2 && pathSegments[0] == 'accounts') {
      return "Account";
    }

    // Default formatting for other paths
    String cleanedPath = currentPath.startsWith('/') ? currentPath.substring(1) : currentPath;
    cleanedPath = cleanedPath.replaceAll("/", " ");
    return cleanedPath.toTitleCase;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = ref.watch(currentRouteProvider);
    final theme = Theme.of(context);

    // Check if we have a parent route to go back to
    final pathSegments = Uri.parse(currentPath).pathSegments;
    final hasParentRoute = pathSegments.length > 1;
    final parentPath = hasParentRoute ? '/${pathSegments.take(pathSegments.length - 1).join('/')}' : null;
    final canPop = hasParentRoute && currentPath != "/";

    return SproutRouteWrapper(
      size: SproutRouteSize.large,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SproutCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (canPop) ...[
                  // Back button
                  InkWell(
                    onTap: () => NavigationProvider.redirect(parentPath ?? ''),
                    customBorder: const LinearBorder(),
                    child: Tooltip(
                      message: "Go back",
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Icon(
                          Icons.arrow_back,
                          size: 28,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
                Padding(
                  padding: EdgeInsets.only(left: canPop ? 8 : 16),
                  child: Text(
                    _getText(ref),
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Help link to documentation
                InkWell(
                  onTap: SettingsPage.openDocumentation,
                  customBorder: const LinearBorder(),
                  child: Tooltip(
                    message: "View Sprout Documentation",
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Icon(
                        Icons.help,
                        size: 28,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                // Notifications
                const NotificationBell(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
