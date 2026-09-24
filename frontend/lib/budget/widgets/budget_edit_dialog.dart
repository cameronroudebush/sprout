import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/budget/provider/budget_provider.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/widgets/info_card.dart';

/// Shows a dialog to create or edit a budget target
void showBudgetEditDialog({
  required BuildContext context,
  CategoryBudgetOverviewItem? item,
}) {
  showSproutPopup(
    context: context,
    builder: (innerContext) => BudgetEditDialogWidget(item: item),
  );
}

class BudgetEditDialogWidget extends ConsumerStatefulWidget {
  final CategoryBudgetOverviewItem? item;

  const BudgetEditDialogWidget({super.key, this.item});

  @override
  ConsumerState<BudgetEditDialogWidget> createState() => _BudgetEditDialogWidgetState();
}

class _BudgetEditDialogWidgetState extends ConsumerState<BudgetEditDialogWidget> {
  late final TextEditingController _amountController;
  Category? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.item != null && widget.item!.budgetedAmount > 0
          ? widget.item!.budgetedAmount.toStringAsFixed(2)
          : '',
    );
    _selectedCategory = widget.item?.category;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target amount')),
      );
      return;
    }

    if (widget.item?.budgetId == null && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final actions = ref.read(budgetActionsProvider);
      if (widget.item?.budgetId != null) {
        await actions.updateBudget(widget.item!.budgetId!, amount);
      } else {
        await actions.createBudget(_selectedCategory!.id, amount);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save budget: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _delete() async {
    if (widget.item?.budgetId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Budget Target?'),
        content: Text('Are you sure you want to delete the budget for "${widget.item!.category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(budgetActionsProvider).deleteBudget(widget.item!.budgetId!);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete budget: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item?.budgetId != null;

    return SproutBaseDialogWidget(
      isEditing ? "Edit Budget Target" : "Add Budget Target",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          InfoCard(
            text: isEditing
                ? "Adjust your target monthly spending limit for this category. Sprout tracks actual spending against this limit."
                : "Set a monthly target spending limit for a category to track spending and get notified if you go over budget.",
          ),
          const SizedBox(height: 16),
          CategoryDropdown(
            _selectedCategory?.id,
            (cat) => setState(() => _selectedCategory = cat),
            enabled: !isEditing && !_isLoading,
            displayAllCategoryButton: false,
            displayUnknownCategoryButton: false,
            label: "Category",
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            enabled: !_isLoading,
            decoration: const InputDecoration(
              labelText: "Monthly Target Amount (\$)",
              hintText: "e.g. 250.00",
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (isEditing) ...[
                IconButton.outlined(
                  onPressed: _isLoading ? null : _delete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: "Delete Budget Target",
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(isEditing ? "Update" : "Save"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
