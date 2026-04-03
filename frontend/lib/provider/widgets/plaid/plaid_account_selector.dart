import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/provider/provider_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';

/// This widget allows us to open plaid link to link an account for access within Sprout. This is just another
///   way to provide automated data to Sprout.
class PlaidAccountSelector extends ConsumerStatefulWidget {
  final ProviderConfig provider;
  final VoidCallback? onSuccess;

  const PlaidAccountSelector({
    super.key,
    required this.provider,
    this.onSuccess,
  });

  @override
  ConsumerState<PlaidAccountSelector> createState() => _PlaidAccountSelectorState();
}

class _PlaidAccountSelectorState extends ConsumerState<PlaidAccountSelector> {
  String? _error;
  StreamSubscription<LinkSuccess>? _successSubscription;

  @override
  void initState() {
    super.initState();
    _successSubscription = PlaidLink.onSuccess.listen(_onPlaidSuccess);
    PlaidLink.onExit.listen((exit) {
      if (exit.error != null) {
        LoggerProvider.error("Plaid Exit Error: ${exit.error?.displayMessage}");
      } else {
        ref
            .read(notificationsProvider.notifier)
            .openFrontendOnly("Plaid link cancelled", type: NotificationTypeEnum.warning);
      }
      Navigator.of(context).pop();
    });
    _initializePlaid();
  }

  @override
  void dispose() {
    _successSubscription?.cancel();
    super.dispose();
  }

  /// Initializes plaid so we can properly create our link tokens
  Future<void> _initializePlaid() async {
    try {
      final api = await ref.read(providerApiProvider.future);
      final response = await api.plaidProviderControllerCreateLinkToken();
      final linkToken = response?.linkToken;
      if (linkToken == null) throw Exception("No link token returned from backend");

      LinkTokenConfiguration configuration = LinkTokenConfiguration(token: linkToken);
      // Create and Open
      await PlaidLink.create(configuration: configuration);
      PlaidLink.open();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ref.read(notificationsProvider.notifier).parseOpenAPIException(e);
        });
      }
    }
  }

  /// What to do on a successful link
  Future<void> _onPlaidSuccess(LinkSuccess success) async {
    if (!mounted) return;

    try {
      final api = ref.read(providerApiProvider).value;

      // Create combined model
      final inst = PlaidInstitutionDTO(
        name: success.metadata.institution?.name ?? "Unknown",
        institutionId: success.metadata.institution?.id ?? "",
      );

      final accounts = success.metadata.accounts
          .map((acc) => PlaidAccountDTO(
                id: acc.id,
                name: acc.name,
                type: acc.type.toString(),
                subtype: acc.subtype.toString(),
                mask: acc.mask,
              ))
          .toList();

      final result = PlaidLinkDTO(
        publicToken: success.publicToken,
        metadata: PlaidMetadataDTO(
          institution: inst,
          accounts: accounts,
          linkSessionId: success.metadata.linkSessionId,
        ),
      );

      await api!.plaidProviderControllerExchangeAndLink(result);

      if (widget.onSuccess != null) widget.onSuccess!();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ref.read(notificationsProvider.notifier).parseOpenAPIException(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return Center(child: Text(_error!, style: TextStyle(color: Colors.red)));

    return const SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Waiting for Plaid..."),
        ],
      ),
    );
  }
}
