import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/category/widgets/category_icon_dropdown.dart';
import 'package:sprout/config/config_provider.dart';
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
  late bool _excludeFromCashFlow;
  late bool _increasedSubVariance;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _selectedIcon = widget.category?.icon ?? "payment";
    _selectedParentId = widget.category?.parentCategoryId;
    _excludeFromCashFlow = widget.category?.excludeFromCashFlow ?? false;
    _increasedSubVariance = widget.category?.increasedSubVariance ?? true;
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
      excludeFromCashFlow: _excludeFromCashFlow,
      increasedSubVariance: _increasedSubVariance,
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
    final theme = Theme.of(context);
    final helpStyle = const TextStyle(fontSize: 12, color: Colors.grey);
    final isDemoMode = ref.watch(unsecureConfigProvider.notifier).isDemoMode();

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _nameController,
      builder: (context, value, child) {
        final bool canSave = value.text.trim().isNotEmpty;
        final isEdit = widget.category != null;

        return SproutBaseDialogWidget(
          isEdit ? "Edit Category" : "New Category",
          showCloseDialogButton: true,
          closeButtonText: "Cancel",
          showSubmitButton: !isDemoMode,
          submitButtonText: "Save",
          allowSubmitClick: canSave,
          onSubmitClick: () => _handleSave(context),
          extraButtons: !isEdit || isDemoMode
              ? null
              : IconButton.filled(
                  style: ThemeHelpers.errorButton,
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete),
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

              // Exclude from cash flow toggle
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Exclude from Cash Flow", style: theme.textTheme.titleMedium),
                        Text("If we should exclude this category from cash flow calculations.", style: helpStyle),
                      ],
                    ),
                  ),
                  Switch(
                    value: _excludeFromCashFlow,
                    onChanged: (newValue) => setState(() => _excludeFromCashFlow = newValue),
                  ),
                ],
              ),

              // Increased sub variance toggle
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Increased subscription variance", style: theme.textTheme.titleMedium),
                        Text(
                            "If this category should allow for a wider variance when trying to auto determine subscriptions. You'll normally want to turn this on for things like utilities.",
                            style: helpStyle),
                      ],
                    ),
                  ),
                  Switch(
                    value: _increasedSubVariance,
                    onChanged: (newValue) => setState(() => _increasedSubVariance = newValue),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
