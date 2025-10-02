import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sprout/category/models/category.dart';
import 'package:sprout/category/provider.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/dialog.dart';
import 'package:sprout/transaction/models/transaction.dart';
import 'package:sprout/transaction/provider.dart';

/// A widget that displays the editing capabilities of a [Transaction]
class TransactionInfo extends StatefulWidget {
  final Transaction transaction;

  /// If fields the backend doesn't support editing should be disabled.
  final bool disableNonEditable;

  const TransactionInfo(this.transaction, {super.key, this.disableNonEditable = true});

  @override
  State<TransactionInfo> createState() => _TransactionInfoState();
}

class _TransactionInfoState extends State<TransactionInfo> {
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
      account: widget.transaction.account, // This should not be editable here
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

    // Compare each field to see if any have changed
    return original.description != current.description ||
        original.amount != current.amount ||
        original.category?.id != current.category?.id ||
        original.posted != current.posted ||
        original.pending != current.pending;
  }

  /// Validates and submits the form changes
  void _submit() {
    final transactionProvider = ServiceLocator.get<TransactionProvider>();

    // Validate the form before proceeding with submission
    if (_formKey.currentState!.validate()) {
      final newTransaction = _getNewTransaction();

      if (_valHasChanged()) {
        // Tell provider to update the transaction
        transactionProvider.editTransaction(newTransaction);
      }

      // Close dialog
      Navigator.of(context).pop();
    }
  }

  /// Shows a date picker to select a new posted date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _postedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _postedDate) {
      setState(() {
        _postedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SproutDialogWidget(
      "Edit Transaction",
      showCloseDialogButton: true,
      closeButtonText: "Cancel",
      showSubmitButton: true,
      // Enable submit only if form is valid and values have changed
      allowSubmitClick: _valHasChanged() && (_formKey.currentState?.validate() ?? false),
      onSubmitClick: _submit,
      child: _getForm(),
    );
  }

  Widget _getForm() {
    final helpStyle = TextStyle(fontSize: 12, color: Colors.grey);

    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        return Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextFormField(
                        enabled: !widget.disableNonEditable,
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: "e.g., 'Coffee Shop'",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a description";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextFormField(
                        controller: _amountController,
                        enabled: !widget.disableNonEditable,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: "e.g., '15.50'", border: OutlineInputBorder()),
                        onChanged: (value) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter an amount";
                          }
                          if (double.tryParse(value) == null) {
                            return "This value must be numerical";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category to assign to
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
                      provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<Category?>(
                              value: _category,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              hint: const Text("Select a category"),
                              items: [
                                const DropdownMenuItem<Category?>(value: null, child: Text("Unknown")),
                                ...provider.categories
                                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat.name)))
                                    .toList(),
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  _category = newValue;
                                });
                              },
                            ),
                      Text("The category this transaction belongs to.", style: helpStyle),
                    ],
                  ),

                  // Posted Date
                  const SizedBox(height: 12),
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
                            onPressed: widget.disableNonEditable ? null : () => _selectDate(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

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
                        onChanged: widget.disableNonEditable
                            ? null
                            : (newValue) {
                                setState(() => _pending = newValue);
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
