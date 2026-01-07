import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_icon.dart';
import 'package:sprout/category/widgets/info.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/dialog.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/core/widgets/page_loading.dart';
import 'package:sprout/core/widgets/state_tracker.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';

/// A widget that displays all of our categories and allows editing and deleting them
class CategoryOverview extends StatefulWidget {
  const CategoryOverview({super.key});

  @override
  State<CategoryOverview> createState() => _CategoryOverviewState();
}

class _CategoryOverviewState extends StateTracker<CategoryOverview> {
  @override
  Map<dynamic, DataRequest> get requests => {
    'cats': DataRequest<CategoryProvider, dynamic>(
      provider: ServiceLocator.get<CategoryProvider>(),
      onLoad: (p, force) => p.loadUpdatedCategories(),
      getFromProvider: (p) => p.categories,
    ),
  };

  Future<void> _openInfoDialog(BuildContext context, Category? c) async {
    await showDialog(context: context, builder: (_) => CategoryInfo(c));
  }

  void _delete(BuildContext context, Category c) {
    final provider = ServiceLocator.get<CategoryProvider>();
    showDialog(
      context: context,
      builder: (_) => SproutDialogWidget(
        'Delete Category',
        showCloseDialogButton: true,
        closeButtonText: "Cancel",
        showSubmitButton: true,
        submitButtonText: "Delete",
        submitButtonStyle: AppTheme.errorButton,
        closeButtonStyle: AppTheme.primaryButton,
        onSubmitClick: () {
          provider.delete(c);
          Navigator.of(context).pop();
        },
        child: const TextWidget(
          text:
              'Removing this category will set all transactions that use it to have the "unknown" category. This cannot be undone.',
        ),
      ),
    );
  }

  /// Helper method to build the UI for a single category list tile.
  Widget _buildCategoryTile(BuildContext context, Category c, int depth) {
    final double indentation = 16.0 * depth;

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return ListTile(
        contentPadding: EdgeInsets.only(left: indentation + 16, right: 16),
        leading: CategoryIcon(c),
        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [const SizedBox(width: 8), _buildActionButtons(context, c, isDesktop)],
        ),
      );
    });
  }

  Widget _buildActionButtons(BuildContext context, Category c, bool isDesktop) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        SproutTooltip(
          message: "Edit Category",
          child: IconButton(
            onPressed: () => _openInfoDialog(context, c),
            icon: const Icon(Icons.edit_outlined),
            style: AppTheme.primaryButton,
            visualDensity: VisualDensity.compact,
          ),
        ),
        SproutTooltip(
          message: "Delete Category",
          child: IconButton(
            onPressed: () => _delete(context, c),
            icon: const Icon(Icons.delete_outline),
            style: AppTheme.errorButton,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  /// Recursively builds the list of category widgets.
  List<Widget> _buildCategoryTree(BuildContext context, Category category, List<Category> allCategories, int depth) {
    final List<Widget> widgets = [];

    // Add the current category's widget with appropriate indentation
    widgets.add(_buildCategoryTile(context, category, depth));

    // Find, sort, and recurse for children
    final children = allCategories.where((c) => c.parentCategory?.id == category.id).toList();
    children.sort((a, b) => a.name.compareTo(b.name));

    for (final child in children) {
      widgets.addAll(_buildCategoryTree(context, child, allCategories, depth + 1));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        final isLoading = this.isLoading;

        if (isLoading) {
          return PageLoadingWidget(loadingText: "Loading Categories...");
        }

        // Find only the top-level categories to start the recursion
        final topLevelCategories = provider.categories.where((c) => c.parentCategory == null).toList();
        topLevelCategories.sort((a, b) => a.name.compareTo(b.name));

        return SingleChildScrollView(
          child: Column(
            children: [
              /// Explanation Card
              SproutCard(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Flexible(
                        child: Text(
                          "Categories allow us to tell Sprout where our money is going.",
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // A single card to hold all categories
              SproutCard(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topLevelCategories.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final parent = topLevelCategories[index];
                    final treeWidgets = _buildCategoryTree(
                      context,
                      parent,
                      provider.categories, // Pass the full list for searching
                      0, // Start at depth 0
                    );
                    return Column(children: treeWidgets);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
