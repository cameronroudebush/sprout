import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_icon.dart';

/// A re-usable dropdown that allows us to select a category
class CategoryDropdown extends ConsumerWidget {
  static final fakeAllCategory = Category(id: "all", name: "All Categories", icon: "category");
  static final unknownCategory = Category(id: "unknown" as dynamic, name: "Unknown", icon: "unknown");

  final Category? selectedParent;
  final String? editingCategoryId;
  final Function(Category? newValue) onChanged;
  final bool displayAllCategoryButton;
  final bool enabled;

  const CategoryDropdown(
    this.selectedParent,
    this.onChanged, {
    super.key,
    this.editingCategoryId,
    this.displayAllCategoryButton = false,
    this.enabled = true,
  });

  /// Helper to render the item content (Icon + Name)
  Widget _getDisplay(Category category) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        CategoryIcon(category, avatarSize: 16),
        Expanded(
          child: Text(
            category.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ],
    );
  }

  /// Recursively builds the list of dropdown menu items with indentation
  List<DropdownMenuItem<Category>> _buildCategoryItems(
    List<Category> allCategories,
    Category currentItem,
    int depth, {
    bool applyPadding = true,
    String? excludeId,
  }) {
    if (excludeId != null && currentItem.id == excludeId) {
      return [];
    }
    final List<DropdownMenuItem<Category>> items = [];
    final double indentation = 16.0 * depth;

    items.add(
      DropdownMenuItem(
        value: currentItem,
        child: Padding(
          padding: applyPadding ? EdgeInsets.only(left: indentation) : EdgeInsets.zero,
          child: _getDisplay(currentItem),
        ),
      ),
    );

    final children = allCategories.where((c) => c.parentCategory?.id == currentItem.id).toList();
    children.sort((a, b) => a.name.compareTo(b.name));

    for (final child in children) {
      items.addAll(
        _buildCategoryItems(allCategories, child, depth + 1, applyPadding: applyPadding, excludeId: excludeId),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return categoriesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (err, _) => const Text("Error loading categories"),
      data: (cats) {
        final categories = [...cats];
        categories.insert(0, unknownCategory);
        if (displayAllCategoryButton) categories.insert(0, fakeAllCategory);
        var selectedValue = categories.firstWhereOrNull((c) => c.id == selectedParent?.id);
        if (displayAllCategoryButton && selectedValue == null) selectedValue = CategoryDropdown.fakeAllCategory;

        // Build the display list
        // Filter out special IDs and parents to get "clean" top-level categories
        final topLevel = cats
            .where(
              (c) =>
                  c.parentCategory == null &&
                  c.id != editingCategoryId &&
                  c.id != fakeAllCategory.id &&
                  c.id != unknownCategory.id,
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        // Pin the specials back to the TOP of the display list
        topLevel.insert(0, unknownCategory);
        if (displayAllCategoryButton) topLevel.insert(0, fakeAllCategory);

        return DropdownButtonFormField<Category>(
          isExpanded: true,
          menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
          dropdownColor: theme.colorScheme.surfaceContainerHighest,
          value: selectedValue,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          hint: const Text("Select a category"),
          selectedItemBuilder: (context) {
            return topLevel
                .expand(
                  (parent) =>
                      _buildCategoryItems(categories, parent, 0, applyPadding: false, excludeId: editingCategoryId),
                )
                .toList();
          },
          items: topLevel
              .expand((parent) => _buildCategoryItems(categories, parent, 0, excludeId: editingCategoryId))
              .toList(),
          onChanged: !enabled ? null : onChanged,
        );
      },
    );
  }
}
