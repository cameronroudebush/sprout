import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/provider/widgets/dialog/provider_selection.dart';
import 'package:sprout/provider/widgets/simple-fin/simple_fin_accounts.dart';
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
  List<Account> _selectedAccounts = [];
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(secureConfigProvider).value;

    Widget content;
    if (_selectedProvider == null) {
      content = ProviderSelectionList(
        providers: config?.providers ?? [],
        onProviderSelected: (p) => setState(() => _selectedProvider = p),
      );
    } else {
      content = SimpleFinAccountSelector(
        provider: _selectedProvider!,
        onSelectionChanged: (accounts) => setState(() => _selectedAccounts = accounts),
      );
    }

    return SproutBaseDialogWidget(
      "Add Accounts",
      showCloseDialogButton: !_isSubmitting,
      showSubmitButton: _selectedProvider != null,
      allowSubmitClick: _selectedAccounts.isNotEmpty && !_isSubmitting,
      onSubmitClick: _handleSubmit,
      child: _isSubmitting ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())) : content,
    );
  }

  /// What to do when we click submit, per provider
  Future<void> _handleSubmit() async {
    if (_selectedProvider == null || _selectedAccounts.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      switch (_selectedProvider!.dbType) {
        case ProviderTypeEnum.simpleFin:
          await SimpleFinAccountSelector.link(ref, _selectedAccounts);
          break;
        case ProviderTypeEnum.zillow:
          // TODO
          // await ProviderLinkHandlers.linkPlaid(ref, _selectedAccounts);
          break;
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ref.read(notificationsProvider.notifier).parseOpenAPIException(e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
