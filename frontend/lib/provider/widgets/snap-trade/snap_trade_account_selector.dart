import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/provider/provider_provider.dart';

import 'snap_trade_helper.dart'; // Import your newly created factory file

class SnapTradeAccountSelector extends ConsumerStatefulWidget {
  final ProviderConfig provider;
  final VoidCallback? onSuccess;

  const SnapTradeAccountSelector({super.key, required this.provider, this.onSuccess});

  /// Asks the recent data to auto link new accounts
  static Future<void> link(WidgetRef ref) async {
    final api = await ref.read(providerApiProvider.future);
    await api.snapTradeProviderControllerPostLink();
  }

  @override
  ConsumerState<SnapTradeAccountSelector> createState() => _SnapTradeAccountSelectorState();
}

class _SnapTradeAccountSelectorState extends ConsumerState<SnapTradeAccountSelector> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeSnapTrade();
  }

  Future<void> _initializeSnapTrade() async {
    final helper = SnapTradeHelper();
    final notificationProvider = ref.read(notificationsProvider.notifier);

    await helper.linkAccount(
      ref,
      onSuccess: () async {
        if (mounted && widget.onSuccess != null) widget.onSuccess!();
      },
      onError: (errorMsg) {
        if (mounted) {
          setState(() {
            _error = notificationProvider.parseOpenAPIException(errorMsg);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }

    return const SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Opening SnapTrade..."),
        ],
      ),
    );
  }
}
