import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/provider/provider_provider.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/state_dropdown.dart';
import 'package:sprout/user/user_config_provider.dart';

/// This widget provides the ability to input a zillow property you want to track
class ZillowPropertySelector extends ConsumerStatefulWidget {
  final ProviderConfig provider;
  final ValueChanged<ZillowPropertyDTO?> onPropertyFound;

  const ZillowPropertySelector({
    super.key,
    required this.provider,
    required this.onPropertyFound,
  });

  /// Given the property info that we want to link, utilizes the API to do such
  static Future<void> link(WidgetRef ref, ZillowPropertyDTO dto) async {
    final api = ref.read(providerApiProvider).value;
    if (api == null) throw Exception("API not initialized");
    await api.zillowProviderControllerLink(dto);
  }

  @override
  ConsumerState<ZillowPropertySelector> createState() => _ZillowPropertySelectorState();
}

class _ZillowPropertySelectorState extends ConsumerState<ZillowPropertySelector> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedState;
  final _zipController = TextEditingController();

  bool _isLoading = false;
  ZillowPropertyResultDto? _lookupResult;
  String? _errorMessage;

  /// Performs the lookup utilizing the zillow endpoint
  Future<void> _performLookup(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _lookupResult = null;
      _errorMessage = null;
      widget.onPropertyFound(null);
    });

    try {
      final api = ref.read(providerApiProvider).value;
      if (api == null) throw Exception("API not initialized");

      final dto = ZillowPropertyDTO(
        address: _addressController.text,
        city: _cityController.text,
        state: _selectedState ?? '',
        zip: int.parse(_zipController.text),
      );
      final result = await api.zillowProviderControllerLookupProperty(dto);
      setState(() => _lookupResult = result);
      widget.onPropertyFound(dto);
    } catch (e) {
      setState(() => _errorMessage = ref.read(notificationsProvider.notifier).parseOpenAPIException(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ref.read(providerApiProvider).value;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Text("Find a property on Zillow", style: theme.textTheme.titleMedium),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: "Street Address", border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: "City", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
              ),
              Expanded(
                flex: 1,
                child: UsStateDropdownField(
                  value: _selectedState,
                  onChanged: (val) => setState(() => _selectedState = val),
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _zipController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Zip Code", border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
          if (_errorMessage != null) ...[
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 40),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 8,
            )
          ],
          if (_isLoading)
            const CircularProgressIndicator()
          else
            FilledButton.icon(
              onPressed: () => _performLookup(ref),
              icon: const Icon(Icons.search),
              label: const Text("Lookup Property"),
            ),
          if (_lookupResult != null) ...[
            const Divider(height: 16),
            _buildResultCard(theme),
          ]
        ],
      ),
    );
  }

  /// Builds a result card that shows what property details we found from our lookup
  Widget _buildResultCard(ThemeData theme) {
    final privateMode = ref.watch(userConfigProvider).value?.privateMode ?? false;
    final zestimate = _lookupResult?.zestimate.toCurrency(privateMode) ?? 'Unknown';
    final rentZestimate = "${_lookupResult?.rentZestimate.toCurrency(privateMode) ?? 'Unknown'}/mo";
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Property Found!",
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          _row("Zillow Property ID", _lookupResult?.zpid ?? "N/A"),
          _row("Zestimate", zestimate),
          _row("Rent Zestimate", rentZestimate),
        ],
      ),
    );
  }

  /// Builds a detail row for a found property value
  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }
}
