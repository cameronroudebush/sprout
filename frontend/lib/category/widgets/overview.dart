import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/provider.dart';
import 'package:sprout/category/widgets/info.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/card.dart';
import 'package:sprout/core/widgets/dialog.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/transaction/widgets/category_icon.dart';

/// A widget that displays all of our categories and allows editing and deleting them
class CategoryOverview extends StatelessWidget {
  const CategoryOverview({super.key});

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

  /// Helper method to build the UI for a single category card.
  Widget _buildCategoryCard(BuildContext context, Category c) {
    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                spacing: 8,
                children: [
                  CategoryIcon(c),
                  if (c.type == CategoryTypeEnum.expense)
                    SproutTooltip(
                      message: "Expense",
                      child: Icon(Icons.arrow_downward, color: Colors.red),
                    ),
                  if (c.type == CategoryTypeEnum.income)
                    SproutTooltip(
                      message: "Expense",
                      child: Icon(Icons.arrow_upward, color: Colors.green),
                    ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24), softWrap: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Edit buttons
            Row(
              spacing: 8,
              children: [
                SproutTooltip(
                  message: "Edit Category",
                  child: IconButton(
                    onPressed: () => _openInfoDialog(context, c),
                    icon: const Icon(Icons.edit_outlined),
                    style: AppTheme.primaryButton,
                  ),
                ),
                SproutTooltip(
                  message: "Delete Category",
                  child: IconButton(
                    onPressed: () => _delete(context, c),
                    icon: const Icon(Icons.delete_outline),
                    style: AppTheme.errorButton,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Recursively builds the list of category widgets.
  List<Widget> _buildCategoryTree(BuildContext context, Category category, List<Category> allCategories, int depth) {
    final List<Widget> widgets = [];
    final double indentation = 32.0 * depth;

    // Add the current category's widget with appropriate indentation
    widgets.add(
      Padding(
        padding: EdgeInsets.only(left: indentation, top: 2.0, bottom: 2.0),
        child: _buildCategoryCard(context, category),
      ),
    );

    // Find, sort, and recurse for children
    final children = allCategories.where((c) => c.parentCategory == category).toList();
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
        if (provider.isLoading) {
          return const SproutCard(
            child: Padding(
              padding: EdgeInsetsGeometry.all(12),
              child: Center(
                child: Column(
                  children: [
                    Text("Loading Categories", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          );
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
                        child: TextWidget(
                          referenceSize: 1.25,
                          text: "Categories allow us to tell Sprout where our money is going.",
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Recursively built list of categories
              ...topLevelCategories.expand(
                (parent) => _buildCategoryTree(
                  context,
                  parent,
                  provider.categories, // Pass the full list for searching
                  0, // Start at depth 0
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
