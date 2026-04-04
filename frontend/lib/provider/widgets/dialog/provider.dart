import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/provider/provider_provider.dart';
import 'package:sprout/provider/widgets/dialog/provider_selection.dart';
import 'package:sprout/provider/widgets/plaid/plaid_account_selector.dart';
import 'package:sprout/provider/widgets/simple-fin/simple_fin_accounts.dart';
import 'package:sprout/provider/widgets/zillow/zillow_property_selector.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';

/// This dialog provides the ability to select from providers and add accounts related to those providers after filling
///   out whatever information they require. It's intended to be dynamic.
class ProviderDialog extends ConsumerStatefulWidget {
  const ProviderDialog({super.key});

  @override
  ConsumerState<ProviderDialog> createState() => _ProviderDialogState();
}

class _ProviderDialogState extends ConsumerState<ProviderDialog> {
  ProviderConfig? _selectedProvider;
  bool _isSubmitting = false;

// Data from the providers
  List<Account> _selectedAccounts = [];
  ZillowPropertyDTO? _zillowPayload;

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(providerConfigProvider).value;

    Widget content = SizedBox.shrink();
    if (_selectedProvider == null) {
      content = ProviderSelectionList(
        providers: providers ?? [],
        onProviderSelected: (p) => setState(() => _selectedProvider = p),
      );
    } else {
      // Switch content based on provider type
      switch (_selectedProvider!.dbType) {
        case ProviderTypeEnum.zillow:
          content = ZillowPropertySelector(
            provider: _selectedProvider!,
            onPropertyFound: (dto) => setState(() => _zillowPayload = dto),
          );
          break;
        case ProviderTypeEnum.simpleFin:
          content = SimpleFinAccountSelector(
            provider: _selectedProvider!,
            onSelectionChanged: (accounts) => setState(() => _selectedAccounts = accounts),
          );
        case ProviderTypeEnum.plaid:
          content = PlaidAccountSelector(
            provider: _selectedProvider!,
            onSuccess: () => _handleSubmit(),
          );
      }
    }

    return SproutBaseDialogWidget(
      _selectedProvider?.dbType == ProviderTypeEnum.zillow ? "Add Asset" : "Add Accounts",
      showCloseDialogButton: !_isSubmitting,
      showSubmitButton: _selectedProvider != null,
      allowSubmitClick: (_selectedAccounts.isNotEmpty || _zillowPayload != null) && !_isSubmitting,
      onSubmitClick: _handleSubmit,
      child: _isSubmitting ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())) : content,
    );
  }

  /// What to do when we click submit, per provider
  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      switch (_selectedProvider!.dbType) {
        case ProviderTypeEnum.simpleFin:
          if (_selectedProvider == null || _selectedAccounts.isEmpty) return;
          await SimpleFinAccountSelector.link(ref, _selectedAccounts);
          break;
        case ProviderTypeEnum.zillow:
          if (_zillowPayload == null) return;
          await ZillowPropertySelector.link(ref, _zillowPayload!);
          break;
        case ProviderTypeEnum.plaid:
          // Plaid handles it's own submission via the their implementation

          ref.read(notificationsProvider.notifier).openFrontendOnly(
              "Plaid accounts linked successfully. Transactions will be available during the next scheduled sync.",
              type: NotificationTypeEnum.success);
          break;
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ref.read(notificationsProvider.notifier).openWithAPIException(e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
