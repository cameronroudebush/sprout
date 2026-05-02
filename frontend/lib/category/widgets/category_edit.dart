import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/category/widgets/category_icon_dropdown.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/theme/helpers.dart';

/// A widget that renders the ability to edit a category
class CategoryEdit extends ConsumerStatefulWidget {
  final Category? category;

  /// A callback that is triggered when a new category is saved.
  /// If provided, this is called instead of the default provider add.
  final Function(Category category)? onAdd;

  const CategoryEdit(this.category, {super.key, this.onAdd});

  @override
  ConsumerState<CategoryEdit> createState() => _CategoryEditState();
}

class _CategoryEditState extends ConsumerState<CategoryEdit> {
  late TextEditingController _nameController;
  String? _selectedIcon;
  String? _selectedParentId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _selectedIcon = widget.category?.icon ?? "payment";
    _selectedParentId = widget.category?.parentCategoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Opens a dialog to confirm that we can delete this category
  void _confirmDelete(BuildContext context) {
    showSproutPopup(
      context: context,
      builder: (_) => SproutBaseDialogWidget(
        'Delete Category',
        showCloseDialogButton: true,
        closeButtonStyle: ThemeHelpers.primaryButton,
        showSubmitButton: true,
        submitButtonText: "Delete",
        submitButtonStyle: ThemeHelpers.errorButton,
        onSubmitClick: () {
          ref.read(categoriesProvider.notifier).delete(widget.category!.id);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        child: const Text('This will set linked transactions to "Unknown". Continue?', textAlign: TextAlign.center),
      ),
    );
  }

  /// What to do when we are ready to save our content
  Future<void> _handleSave(BuildContext context) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final categoryToSave = Category(
      id: widget.category?.id ?? '',
      name: name,
      icon: _selectedIcon,
      parentCategoryId: _selectedParentId,
    );

    if (widget.category == null) {
      final added = await ref.read(categoriesProvider.notifier).add(categoryToSave);
      if (widget.onAdd != null) {
        widget.onAdd!(added!);
      }
    } else {
      await ref.read(categoriesProvider.notifier).edit(categoryToSave);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _nameController,
      builder: (context, value, child) {
        final bool canSave = value.text.trim().isNotEmpty;
        final isEdit = widget.category != null;

        return SproutBaseDialogWidget(
          isEdit ? "Edit Category" : "New Category",
          showCloseDialogButton: true,
          closeButtonText: "Cancel",
          showSubmitButton: true,
          submitButtonText: "Save",
          allowSubmitClick: canSave,
          onSubmitClick: () => _handleSave(context),
          extraButtons: !isEdit
              ? null
              : IconButton.filled(
                  style: ThemeHelpers.errorButton,
                  onPressed: () => _confirmDelete(context),
                  icon: Icon(Icons.delete),
                ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: "Category Name", border: OutlineInputBorder()),
                onSubmitted: (_) => canSave ? _handleSave(context) : null,
              ),
              CategoryIconDropdown(_selectedIcon, (newValue) {
                setState(() => _selectedIcon = newValue);
              }),
              CategoryDropdown(
                _selectedParentId,
                (newValue) => setState(() => _selectedParentId = newValue?.id),
                editingCategoryId: widget.category?.id,
                label: "Parent Category",
              ),
            ],
          ),
        );
      },
    );
  }
}
