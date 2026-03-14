import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/category/widgets/category_icon_dropdown.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/theme/helpers.dart';

/// A widget that renders the ability to edit a category
class CategoryEditSheet extends ConsumerStatefulWidget {
  final Category? category;
  const CategoryEditSheet({super.key, this.category});

  @override
  ConsumerState<CategoryEditSheet> createState() => _CategoryEditSheetState();
}

class _CategoryEditSheetState extends ConsumerState<CategoryEditSheet> {
  late TextEditingController _nameController;
  String? _selectedIcon;
  Category? _selectedParent;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _selectedIcon = widget.category?.icon ?? "payment";
    _selectedParent = widget.category?.parentCategory;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Opens a dialog to confirm that we can delete this category
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SproutBaseDialogWidget(
        'Delete Category',
        showCloseDialogButton: true,
        showSubmitButton: true,
        submitButtonText: "Delete",
        submitButtonStyle: ThemeHelpers.errorButton,
        onSubmitClick: () {
          ref.read(categoriesProvider.notifier).delete(widget.category!.id);
          Navigator.of(context).pop();
        },
        child: const Text('This will set linked transactions to "Unknown". Continue?', textAlign: TextAlign.center),
      ),
    );
  }

  /// What to do when we are ready to save our content
  Future<void> _handleSave(String name, BuildContext context) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final categoryToSave = Category(
      id: widget.category?.id ?? '',
      name: name,
      icon: _selectedIcon,
      parentCategory: _selectedParent,
    );

    if (widget.category == null) {
      await ref.read(categoriesProvider.notifier).add(categoryToSave);
    } else {
      await ref.read(categoriesProvider.notifier).edit(categoryToSave);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Text(widget.category == null ? "New Category" : "Edit Category", style: theme.textTheme.titleLarge),

          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: "Category Name", border: OutlineInputBorder()),
            onSubmitted: (_) => _handleSave(_nameController.text, context),
          ),

          // Icon Selection
          CategoryIconDropdown(_selectedIcon, (newValue) {
            setState(() => _selectedIcon = newValue);
          }),

          // Parent Category Selection
          CategoryDropdown(
            _selectedParent,
            (newValue) => setState(() => _selectedParent = newValue),
            editingCategoryId: widget.category?.id,
          ),

          Row(
            spacing: 12,
            children: [
              if (widget.category != null)
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
                  ),
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context),
                ),
              Expanded(
                child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ),
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nameController,
                  builder: (context, value, child) {
                    final bool canSave = value.text.trim().isNotEmpty;
                    return FilledButton(
                      onPressed: !canSave ? null : () => _handleSave(value.text, context),
                      child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
