import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'snap_trade_helper_stub.dart'
    if (dart.library.html) 'snap_trade_helper_web.dart'
    if (dart.library.io) 'snap_trade_helper_mobile.dart';

/// Class that implements platform specific handling for account linking for the current user.
abstract class SnapTradeHelper {
  factory SnapTradeHelper() => getSnapTradeHelper();

  Future<void> linkAccount(
    WidgetRef ref, {
    required Function onSuccess,
    required Function(String) onError,
  });
}
