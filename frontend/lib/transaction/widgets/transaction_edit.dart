import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/category/widgets/category_edit.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/widgets/notification.dart';
import 'package:sprout/shared/widgets/tooltip.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_rule_edit.dart';

/// A widget that displays the editing capabilities of a [Transaction]
class TransactionEdit extends ConsumerStatefulWidget {
  final Transaction transaction;

  /// If fields the backend doesn't support editing should be disabled. Pending is auto disabled.
  final bool disableNonEditable;

  const TransactionEdit(this.transaction, {super.key, this.disableNonEditable = true});

  @override
  ConsumerState<TransactionEdit> createState() => _TransactionEditState();
}

class _TransactionEditState extends ConsumerState<TransactionEdit> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  Category? _category;
  late DateTime _postedDate;
  late bool _pending;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _descriptionController.text = transaction.description;
    _amountController.text = transaction.amount.toString();
    _category = transaction.category;
    _postedDate = transaction.posted;
    _pending = transaction.pending;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// Returns the form fields as a new transaction object
  Transaction _getNewTransaction() {
    return Transaction(
      id: widget.transaction.id,
      account: widget.transaction.account,
      description: _descriptionController.text,
      amount: double.tryParse(_amountController.text) ?? widget.transaction.amount,
      category: _category,
      posted: _postedDate,
      pending: _pending,
    );
  }

  /// Returns true if the value has changed from the original widget or not
  bool _valHasChanged() {
    final original = widget.transaction;
    final current = _getNewTransaction();

    return original.description != current.description ||
        original.amount != current.amount ||
        original.category?.id != current.category?.id ||
        original.posted != current.posted ||
        original.pending != current.pending;
  }

  /// Validates and submits the form changes
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final newTransaction = _getNewTransaction();

      if (_valHasChanged()) {
        ref.read(transactionsProvider.notifier).editTransaction(newTransaction);
      }

      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _postedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _postedDate) {
      setState(() {
        _postedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SproutBaseDialogWidget(
      "Edit Transaction",
      showCloseDialogButton: true,
      closeButtonText: "Cancel",
      showSubmitButton: true,
      allowSubmitClick: _valHasChanged() && (_formKey.currentState?.validate() ?? false),
      onSubmitClick: _submit,
      child: _getForm(context),
    );
  }

  /// Builds the form that allows actually editing a transaction
  Widget _getForm(BuildContext context) {
    final helpStyle = const TextStyle(fontSize: 12, color: Colors.grey);
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              if (widget.transaction.pending)
                SproutNotificationWidget(
                  SproutNotification(
                    "Pending transactions cannot be edited",
                    theme.colorScheme.error,
                    theme.colorScheme.onError,
                  ),
                ),

              // Description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                      SproutTooltip(
                        message: "Add rule based on description",
                        child: IconButton(
                          icon: const Icon(Icons.rule),
                          onPressed: () async {
                            await showSproutPopup(
                              context: context,
                              builder: (_) => TransactionRuleEdit(null, initialValue: widget.transaction.description),
                            );
                            if (mounted) Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    enabled: !widget.transaction.pending,
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: "e.g., 'Coffee Shop'", border: OutlineInputBorder()),
                    onChanged: (value) => setState(() {}),
                    validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
                  ),
                ],
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  const Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _amountController,
                    enabled: !widget.disableNonEditable && !widget.transaction.pending,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (value) => setState(() {}),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Required";
                      if (double.tryParse(value) == null) return "Must be numerical";
                      return null;
                    },
                  ),
                ],
              ),

              // Category
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
                      SproutTooltip(
                        message: "Add new category",
                        child: IconButton(
                          icon: const Icon(Icons.category),
                          onPressed: () async {
                            await showSproutPopup(
                              context: context,
                              builder: (_) => CategoryEdit(
                                null,
                                onAdd: (category) {
                                  setState(() => _category = category);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  CategoryDropdown(
                    _category,
                    (cat) => setState(() => _category = cat),
                    enabled: !widget.transaction.pending,
                  ),
                  Text("The category this transaction belongs to.", style: helpStyle),
                ],
              ),

              // Posted Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  const Text("Posted Date", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: Text(DateFormat.yMMMd().format(_postedDate), style: const TextStyle(fontSize: 16)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: widget.disableNonEditable || widget.transaction.pending
                            ? null
                            : () => _selectDate(context),
                      ),
                    ],
                  ),
                ],
              ),

              // Pending status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Pending", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("If this transaction is still pending.", style: helpStyle),
                      ],
                    ),
                  ),
                  Switch(
                    value: _pending,
                    onChanged: widget.disableNonEditable ? null : (newValue) => setState(() => _pending = newValue),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
