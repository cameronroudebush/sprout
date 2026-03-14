import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_edit.dart';
import 'package:sprout/category/widgets/category_icon.dart';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5), width: 1),
      ),
      builder: (context) => CategoryEditSheet(category: category),
    );
  }

  /// Builds an individual category with indentation of depth
  Widget _buildCategoryTile(Category c, int depth) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.only(left: (16.0 * depth) + 16, right: 16),
      leading: CategoryIcon(c),
      title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  /// Loading indicator
  Widget _buildShimmerLoading(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        spacing: 12,
        children: [
          // Explanation card
          SproutCard(
            child: Container(
              height: 60,
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
          ),
          // The category options
          SproutCard(
            child: Column(
              children: List.generate(
                8,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    spacing: 16,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      ),
                      Expanded(
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 60,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    return Scaffold(
      floatingActionButton: SproutSpeedDial(
        actions: [FABAction(icon: Icons.add, label: 'New Category', onTap: (context) => _openEditSheet(null))],
      ),
      body: categoriesAsync.when(
        loading: () => _buildShimmerLoading(Theme.of(context)),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (categories) {
          final topLevel = categories.where((c) => c.parentCategory == null).toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              spacing: 12,
              children: [
                SproutCard(
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("Manage your categories and spending buckets.", textAlign: TextAlign.center),
                  ),
                ),
                SproutCard(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topLevel.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) =>
                        Column(children: _buildCategoryTree(topLevel[index], categories, 0)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
