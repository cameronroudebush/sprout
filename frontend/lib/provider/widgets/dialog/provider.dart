import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/provider/models/extensions/provider_type_extension.dart';
import 'package:sprout/provider/provider_provider.dart';
import 'package:sprout/provider/widgets/dialog/provider_selection.dart';
import 'package:sprout/provider/widgets/plaid/plaid_account_selector.dart';
import 'package:sprout/provider/widgets/provider_generic_account_selector.dart';
import 'package:sprout/provider/widgets/snap-trade/snap_trade_account_selector.dart';
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

  void _onProviderSelected(ProviderConfig p) {
    setState(() => _selectedProvider = p);

    // Direct linking providers. These link immediately with no user input.
    if (p.dbType.isDirectLinking) {
      _handleSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final providersAsync = ref.watch(providerConfigProvider);

    Widget content = providersAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "Failed to load providers.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
      data: (providers) {
        if (_selectedProvider == null) {
          return ProviderSelectionList(
            providers: providers!,
            onProviderSelected: _onProviderSelected,
          );
        }

        switch (_selectedProvider!.dbType) {
          case ProviderTypeEnum.zillow:
            return ZillowPropertySelector(
              provider: _selectedProvider!,
              onPropertyFound: (dto) => setState(() => _zillowPayload = dto),
            );
          case ProviderTypeEnum.simpleFin:
            return ProviderGenericAccountSelector(
              provider: _selectedProvider!,
              accountsProvider: simpleFinAccountsProvider,
              onSelectionChanged: (accounts) => setState(() => _selectedAccounts = accounts),
            );
          case ProviderTypeEnum.coinbase:
            return SizedBox(
              height: 150,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      "Connecting to Coinbase...",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          case ProviderTypeEnum.plaid:
            return PlaidAccountSelector(
              provider: _selectedProvider!,
              onSuccess: () => _handleSubmit(),
            );
          case ProviderTypeEnum.snapTrade:
            return SnapTradeAccountSelector(
              provider: _selectedProvider!,
              onSuccess: () => _handleSubmit(),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );

    return SproutBaseDialogWidget(
      _selectedProvider?.dbType == ProviderTypeEnum.zillow ? "Add Asset" : "Add Accounts",
      showCloseDialogButton: !_isSubmitting,
      showSubmitButton: _selectedProvider != null && !_selectedProvider!.dbType.isDirectLinking,
      allowSubmitClick: (_selectedAccounts.isNotEmpty || _zillowPayload != null) && !_isSubmitting,
      onSubmitClick: _handleSubmit,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Offstage(
            offstage: _isSubmitting && !(_selectedProvider?.dbType.isDirectLinking ?? false),
            child: content,
          ),
          if (_isSubmitting && !(_selectedProvider?.dbType.isDirectLinking ?? false))
            const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  /// What to do when we click submit, per provider
  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    final notificationProvider = ref.read(notificationsProvider.notifier);
    bool isClosing = false;

    try {
      switch (_selectedProvider!.dbType) {
        case ProviderTypeEnum.simpleFin:
          await ProviderGenericAccountSelector.link(
            ref,
            _selectedAccounts,
            (api, accounts) => api.simpleFinProviderControllerLinkAccounts(accounts),
          );
          break;
        case ProviderTypeEnum.coinbase:
          final api = await ref.read(providerApiProvider.future);
          await api.coinbaseProviderControllerLinkAccount();
          notificationProvider.openFrontendOnly(
            "Coinbase account linked successfully.",
            type: NotificationTypeEnum.success,
          );
          break;
        case ProviderTypeEnum.zillow:
          if (_zillowPayload == null) return;
          await ZillowPropertySelector.link(ref, _zillowPayload!);
          break;
        case ProviderTypeEnum.plaid:
          // Plaid handles its own submission via their implementation
          notificationProvider.openFrontendOnly(
            "Plaid accounts linked successfully. Transactions will be available during the next scheduled sync.",
            type: NotificationTypeEnum.success,
          );
          break;
        case ProviderTypeEnum.snapTrade:
          await SnapTradeAccountSelector.link(ref);
          notificationProvider.openFrontendOnly(
            "SnapTrade link successful. Accounts will appear shortly.",
            type: NotificationTypeEnum.info,
          );
          break;
      }

      if (mounted) {
        isClosing = true;
        Navigator.of(context).pop();
      }
    } catch (e) {
      notificationProvider.openWithAPIException(e);
      if (mounted && _selectedProvider != null && _selectedProvider!.dbType.isDirectLinking) {
        isClosing = true;
        Navigator.of(context).pop();
      }
    } finally {
      // Only set to false if we are NOT closing the dialog
      if (mounted && !isClosing) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
