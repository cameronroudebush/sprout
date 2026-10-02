import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_edit.dart';
import 'package:sprout/category/widgets/category_icon.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/speed_dial.dart';

/// This page displays the category overview and allows adding and editing of our available categories
class CategoryOverviewPage extends ConsumerStatefulWidget {
  const CategoryOverviewPage({super.key});

  @override
  ConsumerState<CategoryOverviewPage> createState() =>
      _CategoryOverviewPageState();
}

class _CategoryOverviewPageState extends ConsumerState<CategoryOverviewPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Opens the edit dialog
  void _openEditSheet(Category? category) {
    showSproutPopup(
        context: context, builder: (context) => CategoryEdit(category));
  }

  /// Builds an individual category with indentation of depth
  Widget _buildCategoryTile(Category c, int depth) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.only(left: (16.0 * depth) + 16, right: 16),
      leading: CategoryIcon(c),
      title: Text(c.name, style: theme.textTheme.bodyLarge),
      onTap: () => _openEditSheet(c),
      trailing: Icon(Icons.chevron_right),
    );
  }

  /// Builds the overall category tree utilizing nesting capabilities
  List<Widget> _buildCategoryTree(
      Category category, List<Category> all, int depth, String searchQuery) {
    final children = all
        .where((c) => c.parentCategoryId == category.id)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final List<Widget> widgets = [];
    final List<Widget> childWidgets = [];
    for (final child in children) {
      childWidgets
          .addAll(_buildCategoryTree(child, all, depth + 1, searchQuery));
    }

    if (searchQuery.isEmpty ||
        category.name.toLowerCase().contains(searchQuery) ||
        childWidgets.isNotEmpty) {
      widgets.add(_buildCategoryTile(category, depth));
    }
    widgets.addAll(childWidgets);
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      floatingActionButton: SproutSpeedDial(
        actions: [
          FABAction(
              icon: Icons.add,
              label: 'New Category',
              onTap: (context) => _openEditSheet(null))
        ],
      ),
      body: categoriesAsync.whenDefault(
        emptyCondition: (_) => false,
        data: (categories) {
          final searchQuery = _searchController.text.trim().toLowerCase();
          final topLevel = categories
              .where((c) => c.parentCategoryId == null)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          final List<Widget> allTiles = [];
          for (final root in topLevel) {
            allTiles
                .addAll(_buildCategoryTree(root, categories, 0, searchQuery));
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SproutRouteWrapper(
              child: Column(
                children: [
                  SproutCard(
                    child: const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text("Organize transactions"),
                      subtitle: Text(
                        "Use parent categories for broad groups and subcategories for detail. Assign either to transactions or rules. Category settings can exclude spending from cash flow or adjust recurring-bill detection.",
                      ),
                    ),
                  ),

                  SproutCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search categories...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: searchQuery.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear search',
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    ),
                              isDense: true,
                              border: const OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.search,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (allTiles.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: searchQuery.isEmpty
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 12,
                                    children: [
                                      const Text(
                                        'No categories yet. Add one to start organizing transactions.',
                                        textAlign: TextAlign.center,
                                      ),
                                      FilledButton.icon(
                                        onPressed: () => _openEditSheet(null),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add category'),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'No categories match your search.',
                                    textAlign: TextAlign.center,
                                  ),
                          )
                        else
                          for (int i = 0; i < allTiles.length; i++) ...[
                            allTiles[i],
                            if (i < allTiles.length - 1)
                              const Divider(height: 1, thickness: 1),
                          ],
                      ],
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
