import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

/// A route location and label shown in a breadcrumb trail.
class SproutBreadcrumbItem {
  final String label;
  final String location;

  const SproutBreadcrumbItem({required this.label, required this.location});
}

/// Displays route breadcrumbs, with earlier items navigating to their location.
class SproutBreadcrumbs extends StatelessWidget {
  final List<SproutBreadcrumbItem> items;

  const SproutBreadcrumbs({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0)
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          if (index == items.length - 1)
            Text(
              items[index].label,
              style: theme.textTheme.titleLarge,
            )
          else
            TextButton(
              onPressed: () => context.go(items[index].location),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: const Size(0, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8), // Adjust this value to control rounding
                ),
              ),
              child: Text(items[index].label),
            ),
        ],
      ],
    );
  }
}
