import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_icon.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/category/widgets/category_edit.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/notification.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_map.dart';
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
  String? _categoryId;
  late DateTime _postedDate;
  late bool _pending;

  @override
  void initState() {
    final formatter = ref.read(currencyFormatterProvider);
    super.initState();
    final transaction = widget.transaction;
    _descriptionController.text = transaction.description;
    _amountController.text = formatter.format(transaction.amount);
    _categoryId = transaction.categoryId;
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
      accountId: widget.transaction.accountId,
      description: _descriptionController.text,
      amount: double.tryParse(_amountController.text) ?? widget.transaction.amount,
      categoryId: _categoryId,
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
        original.categoryId != current.categoryId ||
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
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _postedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_postedDate),
      );

      if (pickedTime != null) {
        setState(() {
          _postedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  /// Shows a confirmation dialog to actually execute a transaction delete
  Future<void> _confirmDelete(BuildContext context, ThemeData theme) async {
    showSproutPopup(
      context: context,
      builder: (ctx) => SproutBaseDialogWidget(
        "Delete Transaction",
        showCloseDialogButton: true,
        closeButtonText: "Cancel",
        showSubmitButton: true,
        submitButtonText: "Delete",
        submitButtonStyle: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
        ),
        onSubmitClick: () async {
          Navigator.of(ctx).pop();
          await ref.read(transactionApiProvider).value?.transactionControllerDelete(widget.transaction.id);
          if (mounted) Navigator.of(context).pop();
        },
        child: const Text(
          "Are you sure you want to permanently delete this transaction?\n\nThis action cannot be undone.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDemoMode = ref.watch(unsecureConfigProvider.notifier).isDemoMode();

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      final extra = widget.transaction.extra;
      final hasLocation = extra?.location?.lat != null && extra?.location?.lon != null;
      final maxDesktopWidth = (isDesktop && hasLocation) ? 1024.0 : 640.0;

      return SproutBaseDialogWidget(
        "Edit Transaction",
        maxDesktopWidth: maxDesktopWidth,
        showCloseDialogButton: true,
        closeButtonText: "Cancel",
        showSubmitButton: !isDemoMode,
        allowSubmitClick: _valHasChanged() && (_formKey.currentState?.validate() ?? false),
        onSubmitClick: _submit,
        extraButtons: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: isDemoMode ? null : () => _confirmDelete(context, theme),
          icon: const Icon(Icons.delete_outline),
          label: const Text("Delete"),
        ),
        child: _getForm(context, theme, isDesktop),
      );
    });
  }

  /// Builds the form that allows actually editing a transaction
  Widget _getForm(BuildContext context, ThemeData theme, bool isDesktop) {
    final helpStyle = const TextStyle(fontSize: 12, color: Colors.grey);

    // Extract location data if it exists
    final extra = widget.transaction.extra;
    final locationData = extra?.location;
    final double? lat = locationData?.lat?.toDouble();
    final double? lon = locationData?.lon?.toDouble();
    // Only show the map if we have coordinates
    final bool hasLocation = lat != null && lon != null;

    final fields = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        if (widget.transaction.pending)
          SproutNotificationWidget(
            SproutNotification(
              "Pending transactions cannot be edited",
              theme.colorScheme.error,
              theme.colorScheme.onError,
            ),
          ),

        _buildAccountDisplay(theme),

        // Description
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Description", style: theme.textTheme.titleMedium),
                Tooltip(
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
            Text("Amount", style: theme.textTheme.titleMedium),
            TextFormField(
              controller: _amountController,
              enabled: !widget.disableNonEditable && !widget.transaction.pending,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: (value) => setState(() {}),
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
                Text("Category", style: theme.textTheme.titleMedium),
                Tooltip(
                  message: "Add new category",
                  child: IconButton(
                    icon: const Icon(Icons.category),
                    onPressed: () async {
                      await showSproutPopup(
                        context: context,
                        builder: (_) => CategoryEdit(
                          null,
                          onAdd: (category) {
                            setState(() => _categoryId = category.id);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            CategoryDropdown(_categoryId, (cat) => setState(() => _categoryId = cat?.id),
                enabled: !widget.transaction.pending, label: ""),
            Text("The category this transaction belongs to.", style: helpStyle),
          ],
        ),

        // Posted Date
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text("Posted Date", style: theme.textTheme.titleMedium),
            InkWell(
              onTap: widget.disableNonEditable || widget.transaction.pending ? null : () => _selectDate(context),
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  enabled: !(widget.disableNonEditable || widget.transaction.pending),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat("MMM d, yyyy 'at' h:mm a").format(_postedDate),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: (widget.disableNonEditable || widget.transaction.pending) ? theme.disabledColor : null,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color:
                          (widget.disableNonEditable || widget.transaction.pending) ? theme.disabledColor : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Pending status
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pending", style: theme.textTheme.titleMedium),
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
        ),

        // Render Location Map inline only if we're on mobile
        if (!isDesktop && hasLocation)
          _buildLocationSection(theme, lat, lon, locationData, helpStyle, isDesktop: isDesktop),
      ],
    );

    // Desktop Layout (Side-by-side) vs Mobile Layout (Stacked)
    Widget formContent;

    if (isDesktop && hasLocation) {
      formContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          Expanded(flex: 5, child: fields),
          Expanded(
            flex: 4,
            child: _buildLocationSection(theme, lat, lon, locationData, helpStyle, isDesktop: isDesktop),
          ),
        ],
      );
    } else {
      formContent = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: fields,
      );
    }

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        child: formContent,
      ),
    );
  }

  /// Builds the Account Display widget to see what account the transaction is tied to
  Widget _buildAccountDisplay(ThemeData theme) {
    final accounts = ref.watch(accountsProvider).value?.accounts;
    final account = accounts?.firstWhereOrNull((a) => a.id == widget.transaction.accountId);

    if (account == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text("Account", style: theme.textTheme.titleMedium),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            spacing: 12,
            children: [
              AccountIcon(account, size: 28),
              Expanded(
                child: Text(
                  account.name,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a nice location map for where the transaction occurred, assuming we have that data.
  Widget _buildLocationSection(
      ThemeData theme, double lat, double lon, TransactionLocation? locationData, TextStyle helpStyle,
      {bool isDesktop = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        if (!isDesktop) const Divider(height: 24),
        Text("Location", style: theme.textTheme.titleMedium),
        if (locationData?.address != null || locationData?.city != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "${locationData?.address ?? ''} ${locationData?.city ?? ''}".trim(),
              style: helpStyle,
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: isDesktop ? 300 : 200,
            width: double.infinity,
            child: TransactionMapWidget(
              latitude: lat,
              longitude: lon,
            ),
          ),
        ),
      ],
    );
  }
}
