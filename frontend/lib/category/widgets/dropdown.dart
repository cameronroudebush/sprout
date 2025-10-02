import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/category/models/category.dart';
import 'package:sprout/category/provider.dart';

/// A dropdown that allows category selection
class CategoryDropdown extends StatelessWidget {
  final Category? category;
  final Function(Category? newValue) onChanged;

  const CategoryDropdown(this.category, this.onChanged, {super.key});

  /// Recursively builds the list of dropdown menu items with indentation for children.
  List<DropdownMenuItem<Category>> _buildCategoryItems(List<Category> allCategories, Category category, int depth) {
    final List<DropdownMenuItem<Category>> items = [];
    final double indentation = 16.0 * depth;

    // Add the current category's item
    items.add(
      DropdownMenuItem(
        value: category,
        child: Padding(
          padding: EdgeInsets.only(left: indentation),
          child: Text(category.name),
        ),
      ),
    );

    // Find, sort, and recurse for children
    final children = allCategories.where((c) => c.parentCategory == category).toList();
    children.sort((a, b) => a.name.compareTo(b.name));

    for (final child in children) {
      items.addAll(_buildCategoryItems(allCategories, child, depth + 1));
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
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text("Select a category"),
                items: [
                  const DropdownMenuItem<Category>(value: null, child: Text("Unknown")),
                  // Find top-level categories to start the tree
                  ...() {
                    final topLevel = provider.categories.where((c) => c.parentCategory == null).toList();
                    topLevel.sort((a, b) => a.name.compareTo(b.name));

                    return topLevel.expand(
                      (parent) => _buildCategoryItems(
                        provider.categories,
                        parent,
                        0, // Start at depth 0
                      ),
                    );
                  }(),
                ],
                onChanged: onChanged,
              );
      },
    );
  }
}
