import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_edit.dart';
import 'package:sprout/category/widgets/category_icon.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/speed_dial.dart';

/// This page displays the category overview and allows adding and editing of our available categories
class CategoryOverviewPage extends ConsumerStatefulWidget {
  const CategoryOverviewPage({super.key});

  @override
  ConsumerState<CategoryOverviewPage> createState() => _CategoryOverviewPageState();
}

class _CategoryOverviewPageState extends ConsumerState<CategoryOverviewPage> {
  /// Opens the edit dialog
  void _openEditSheet(Category? category) {
    showSproutPopup(context: context, builder: (context) => CategoryEdit(category));
  }

  /// Builds an individual category with indentation of depth
  Widget _buildCategoryTile(Category c, int depth) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.only(left: (16.0 * depth) + 16, right: 16),
      leading: CategoryIcon(c),
      title: Text(c.name, style: theme.textTheme.bodyLarge),
      onTap: () => _openEditSheet(c),
      trailing: Icon(Icons.chevron_right, color: theme.dividerColor),
    );
  }

  /// Builds the overall category tree utilizing nesting capabilities
  List<Widget> _buildCategoryTree(Category category, List<Category> all, int depth) {
    final List<Widget> widgets = [_buildCategoryTile(category, depth)];
    final children = all.where((c) => c.parentCategory?.id == category.id).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    for (final child in children) {
      widgets.addAll(_buildCategoryTree(child, all, depth + 1));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    return Scaffold(
      floatingActionButton: SproutSpeedDial(
        actions: [FABAction(icon: Icons.add, label: 'New Category', onTap: (context) => _openEditSheet(null))],
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (categories) {
          final topLevel = categories.where((c) => c.parentCategory == null).toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SproutRouteWrapper(
              child: Column(
                spacing: 12,
                children: [
                  SproutCard(
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          "Manage your categories and spending buckets.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  SproutCard(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: topLevel.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return Column(
                          children: _buildCategoryTree(topLevel[index], categories, 0),
                        );
                      },
                    ),
                  ),
                  // Padding for FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
