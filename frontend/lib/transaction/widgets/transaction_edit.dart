import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/category/widgets/category_edit.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/notification.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_rule_edit.dart';
import 'package:sprout/user/user_config_provider.dart';

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
  /// Dark filter used to apply to tile servers to invert their colors
  final darkFilter = const ColorFilter.mode(Colors.white, BlendMode.difference);

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDemoMode = ref.watch(unsecureConfigProvider.notifier).isDemoMode();
    return SproutBaseDialogWidget(
      "Edit Transaction",
      showCloseDialogButton: true,
      closeButtonText: "Cancel",
      showSubmitButton: !isDemoMode,
      allowSubmitClick: _valHasChanged() && (_formKey.currentState?.validate() ?? false),
      onSubmitClick: _submit,
      child: SizedBox(
        width: 500,
        child: _getForm(context, theme),
      ),
    );
  }

  /// Builds the form that allows actually editing a transaction
  Widget _getForm(BuildContext context, ThemeData theme) {
    final helpStyle = const TextStyle(fontSize: 12, color: Colors.grey);

    // Watch for the tile server URL from your config
    final tileServer = ref.watch(secureConfigProvider).value?.tileServer;
    final isDarkMode = ref.watch(userConfigProvider.notifier).isDarkMode();

    // Extract location data if it exists
    final extra = widget.transaction.extra;
    final locationData = extra?.location;
    final double? lat = locationData?.lat?.toDouble();
    final double? lon = locationData?.lon?.toDouble();
    // Only show the map if we have coordinates AND a valid tile server
    final bool hasLocation = lat != null && lon != null && tileServer != null && tileServer.isNotEmpty;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
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
                              color: (widget.disableNonEditable || widget.transaction.pending)
                                  ? theme.disabledColor
                                  : null,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: (widget.disableNonEditable || widget.transaction.pending)
                                ? theme.disabledColor
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Pending status
              Padding(
                padding: EdgeInsetsGeometry.only(top: 4),
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

              // Location Map
              if (hasLocation) _buildLocationSection(theme, isDarkMode, lat, lon, locationData, tileServer),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a nice location map for where we're at
  Widget _buildLocationSection(
    ThemeData theme,
    bool isDarkMode,
    double lat,
    double lon,
    TransactionLocation? locationData,
    String tileServer,
  ) {
    final helpStyle = const TextStyle(fontSize: 12, color: Colors.grey);

    final tileLayer = TileLayer(urlTemplate: tileServer, userAgentPackageName: "sprout.croudebush.net");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const Divider(height: 24),
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
            height: 200,
            width: double.infinity,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, lon),
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                isDarkMode ? ColorFiltered(colorFilter: darkFilter, child: tileLayer) : tileLayer,
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(lat, lon),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
