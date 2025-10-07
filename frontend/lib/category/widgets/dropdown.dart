import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/category/models/category.dart';
import 'package:sprout/category/provider.dart';

/// A dropdown that allows category selection
class CategoryDropdown extends StatelessWidget {
  /// Fake all category used for searching
  static final fakeAllCategory = const Category(id: "", name: "All Categories", type: CategoryType.expense);

  final Category? category;
  final Function(Category? newValue) onChanged;

  /// If we want an "all categories" button. Normally used for searching.
  final bool displayAllCategoryButton;

  final bool enabled;

  const CategoryDropdown(
    this.category,
    this.onChanged, {
    super.key,
    this.displayAllCategoryButton = false,
    this.enabled = true,
  });

  /// Recursively builds the list of dropdown menu items with indentation for children.
  List<DropdownMenuItem<Category>> _buildCategoryItems(
    List<Category> allCategories,
    Category category,
    int depth, {
    bool applyPadding = true,
  }) {
    final List<DropdownMenuItem<Category>> items = [];
    final double indentation = 16.0 * depth;

    // Add the current category's item
    items.add(
      DropdownMenuItem(
        value: category,
        child: Padding(
          padding: applyPadding ? EdgeInsets.only(left: indentation) : EdgeInsets.zero,
          child: Text(category.name, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ),
    );

    // Find, sort, and recurse for children
    final children = allCategories.where((c) => c.parentCategory == category).toList();
    children.sort((a, b) => a.name.compareTo(b.name));

    for (final child in children) {
      items.addAll(_buildCategoryItems(allCategories, child, depth + 1, applyPadding: applyPadding));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        return provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<Category>(
                menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                value: category,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                hint: const Text("Select a category"),
                selectedItemBuilder: (BuildContext context) {
                  // We use this so we don't have indentation when displaying the options in the button
                  return [
                    if (displayAllCategoryButton) Text(fakeAllCategory.name),
                    Text("Unknown"),

                    /// Render tree in order
                    ...() {
                      final topLevel = provider.categories.where((c) => c.parentCategory == null).toList();
                      topLevel.sort((a, b) => a.name.compareTo(b.name));

                      return topLevel.expand(
                        (parent) => _buildCategoryItems(provider.categories, parent, 0, applyPadding: false),
                      );
                    }(),
                  ];
                },
                items: [
                  if (displayAllCategoryButton)
                    DropdownMenuItem<Category>(value: fakeAllCategory, child: Text(fakeAllCategory.name)),
                  const DropdownMenuItem<Category>(value: null, child: Text("Unknown")),

                  // Find top-level categories to start the tree
                  ...() {
                    final topLevel = provider.categories.where((c) => c.parentCategory == null).toList();
                    topLevel.sort((a, b) => a.name.compareTo(b.name));

                    return topLevel.expand((parent) => _buildCategoryItems(provider.categories, parent, 0));
                  }(),
                ],
                onChanged: !enabled ? null : onChanged,
              );
      },
    );
  }
}
