import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/notification/widgets/notification_bell.dart';
import 'package:sprout/routes/reports.dart';
import 'package:sprout/routes/settings.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/routes/util/mobile_more_sheet.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/routes/util/route.dart';
import 'package:sprout/routes/util/routes.dart';
import 'package:sprout/shared/models/extensions/string_extensions.dart';
import 'package:sprout/shared/widgets/breadcrumbs.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/tab_selector.dart';

/// A widget that displays the header bar for desktop
class SproutDesktopHeader extends ConsumerWidget {
  /// Current route state, including query parameters used to select header tabs.
  final GoRouterState? state;

  const SproutDesktopHeader({super.key, this.state});

  /// Builds breadcrumb labels and locations for the current route.
  List<SproutBreadcrumbItem> _getBreadcrumbs(WidgetRef ref, Uri uri) {
    if (uri.path == "/") {
      final user = ref.watch(authProvider).value;
      final greeting = SproutMoreSheet.getGreeting();
      return [
        SproutBreadcrumbItem(
          label: "$greeting ${user?.username}",
          location: "/",
        ),
      ];
    }

    final breadcrumbs = <SproutBreadcrumbItem>[];
    var routes = authenticatedRoutes;
    var location = "";

    for (final segment in uri.pathSegments) {
      SproutRoute? route;
      for (final candidate in routes) {
        if (_matchesRouteSegment(candidate, segment)) {
          route = candidate;
          break;
        }
      }
      location = "$location/$segment";
      breadcrumbs.add(
        SproutBreadcrumbItem(
          label: route?.label ?? segment.toPrettyCase,
          location: location,
        ),
      );
      routes = route?.routes ?? const [];
    }

    return breadcrumbs;
  }

  bool _matchesRouteSegment(SproutRoute route, String segment) {
    final routeSegments =
        route.path.split('/').where((part) => part.isNotEmpty);
    if (routeSegments.length != 1) return false;

    final routeSegment = routeSegments.first;
    return routeSegment.startsWith(':') || routeSegment == segment;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final uri = state?.uri ?? GoRouterState.of(context).uri;
    final pageTabs = _buildPageTabs(context, uri);
    final breadcrumbs = _getBreadcrumbs(ref, uri);

    return SproutRouteWrapper(
      size: SproutRouteSize.large,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SproutCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left side (Breadcrumbs) wrapped in Expanded to balance the right side
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SproutBreadcrumbs(items: breadcrumbs),
                ),
              ),
            ),

            // Centered Tabs (if available)
            if (pageTabs != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: pageTabs,
              ),

            // Right side (Actions) wrapped in Expanded to balance the left side
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Help link to documentation
                    InkWell(
                      onTap: SettingsPage.openDocumentation,
                      customBorder: const LinearBorder(),
                      child: Tooltip(
                        message: "View Sprout Documentation",
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds route-specific tabs and binds each choice to its deep-link query key.
  Widget? _buildPageTabs(BuildContext context, Uri uri) {
    final pathSegments = uri.pathSegments;
    final List<SproutTabOption<String>>? options;
    final String queryKey;
    if (pathSegments.length == 2 && pathSegments.first == 'accounts') {
      queryKey = 'tab';
      options = const [
        SproutTabOption(value: 'overview', label: 'Overview'),
        SproutTabOption(value: 'activity', label: 'Activity'),
      ];
    } else if (uri.path == '/holdings') {
      queryKey = 'tab';
      options = const [
        SproutTabOption(value: 'overview', label: 'Overview'),
        SproutTabOption(value: 'holdings', label: 'Holdings'),
      ];
    } else if (uri.path == '/reports') {
      queryKey = 'report';
      options = ReportsPage.reportTabs;
    } else {
      return null;
    }

    final selected = uri.queryParameters[queryKey];
    final selectedValue = options.any((option) => option.value == selected)
        ? selected!
        : options.first.value;

    return SproutTabSelector<String>(
      options: options,
      selected: selectedValue,
      onSelected: (value) => NavigationProvider.updateQueryParameters(
        context,
        {queryKey: value},
        currentUri: uri,
      ),
    );
  }
}
