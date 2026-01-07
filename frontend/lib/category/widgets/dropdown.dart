import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_icon.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/state_tracker.dart';

/// A dropdown that allows category selection
class CategoryDropdown extends StatefulWidget {
  /// Fake all category used for searching
  static final fakeAllCategory = Category(id: "", name: "All Categories");

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

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends StateTracker<CategoryDropdown> {
  @override
  Map<dynamic, DataRequest> get requests => {
    'cats': DataRequest<CategoryProvider, dynamic>(
      provider: ServiceLocator.get<CategoryProvider>(),
      onLoad: (p, force) => p.loadUpdatedCategories(),
      getFromProvider: (p) => p.categories,
    ),
  };

  /// Returns how to display the given category info
  Widget _getDisplay(Category? category) {
    return Row(
      spacing: 4,
      children: [
        CategoryIcon(category ?? Category(id: "", name: "", icon: "unknown"), avatarSize: 16),
        Text(category?.name ?? 'Unknown', overflow: TextOverflow.ellipsis, maxLines: 1),
      ],
    );
  }

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
          child: _getDisplay(category),
        ),
      ),
    );

    // Find, sort, and recurse for children
    final children = allCategories.where((c) => c.parentCategory?.id == category.id).toList();
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
        return isLoading || provider.categories.isEmpty
            ? const Padding(
                padding: EdgeInsetsGeometry.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    SizedBox(height: 24, width: 24, child: CircularProgressIndicator()),
                    Text("Loading categories"),
                  ],
                ),
              )
            : DropdownButtonFormField<Category>(
                menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                value: widget.category,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                hint: const Text("Select a category"),
                selectedItemBuilder: (BuildContext context) {
                  // We use this so we don't have indentation when displaying the options in the button
                  return [
                    if (widget.displayAllCategoryButton) Text(CategoryDropdown.fakeAllCategory.name),
                    _getDisplay(null),

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
                  if (widget.displayAllCategoryButton)
                    DropdownMenuItem<Category>(
                      value: CategoryDropdown.fakeAllCategory,
                      child: Text(CategoryDropdown.fakeAllCategory.name),
                    ),
                  DropdownMenuItem<Category>(value: null, child: _getDisplay(null)),

                  // Find top-level categories to start the tree
                  ...() {
                    final topLevel = provider.categories.where((c) => c.parentCategory == null).toList();
                    topLevel.sort((a, b) => a.name.compareTo(b.name));

                    return topLevel.expand((parent) => _buildCategoryItems(provider.categories, parent, 0));
                  }(),
                ],
                onChanged: !widget.enabled ? null : widget.onChanged,
              );
      },
    );
  }
}
