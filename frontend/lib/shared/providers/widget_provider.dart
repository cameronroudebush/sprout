import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/net-worth/models/extensions/entity_history_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/models/extensions/date_extensions.dart';
import 'package:sprout/shared/providers/sse_provider.dart';
import 'package:sprout/shared/widgets/charts/models/chart_range.dart';
import 'package:sprout/transaction/models/extensions/transaction_extensions.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/user/user_config_provider.dart';
import 'package:workmanager/workmanager.dart';

part 'widget_provider.g.dart';

@Riverpod(keepAlive: true)
class WidgetSync extends _$WidgetSync {
  @override
  void build() {
    if (!kIsWeb) {
      initializeBackground();

      // Listen to the auth state to trigger the initial setup
      ref.listen(authProvider, (prev, next) {
        final user = next.value;

        if (user != null && prev?.value == null) {
          // User just logged in
          _setupAndInitialSync();
        } else if (user == null && prev?.value != null) {
          // User logged out - wipe data
          _saveToNative(null);
        }
      });

      /// Listen for SSE events to trigger immediate widget updates.
      ref.listen(sseProvider, (prev, next) async {
        final data = next.latestData;
        if (data?.event == SSEDataEventEnum.forceUpdate) {
          await update();
        }
      });
    }
  }

  /// Initializes the [Workmanager] and registers a periodic background task.
  ///
  /// This task runs hourly to ensure the Home Screen widget stays up to date
  /// even when the app is not in the foreground.
  Future<void> initializeBackground() async {
    Workmanager().initialize(callbackDispatcher);
    Workmanager().registerPeriodicTask(
      "widget-update-background",
      "widget-update-task",
      frequency: const Duration(hours: 1),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  /// Sets up the background worker and runs the first update
  Future<void> _setupAndInitialSync() async {
    await initializeBackground();
    await update();
  }

  /// The primary entry point for updating native widget data.
  ///
  /// Checks the user's [allowWidgets] preference before proceeding. If disabled,
  /// it clears the widget data to ensure privacy.
  Future<void> update() async {
    final config = await ref.read(userConfigProvider.future);

    // Safety check: If widgets aren't allowed, clear existing data
    if (config == null || !config.allowWidgets) {
      await _saveToNative(null);
      return;
    }

    final data = await _prepareData();
    if (data != null) {
      await _saveToNative(data);
    }
  }

  /// Aggregates data from [NetWorth] and [Transactions] providers.
  Future<Map<String, dynamic>?> _prepareData() async {
    final netWorth = ref.read(totalNetWorthProvider).value;
    final transactions = ref.read(transactionsProvider).value?.transactions ?? [];
    final userConfig = ref.read(userConfigProvider).value;
    final theme = ref.read(userConfigProvider.notifier).getTheme(userConfig);
    final isPrivate = false; // Set to false so widget info always shows real values
    if (netWorth == null) return null;

    final monthFrame = netWorth.history.getValueByFrame(ChartRangeEnum.oneMonth);
    final dayRange = ChartRangeEnum.oneMonth;
    final pastValueRange = netWorth.history.getValueByFrame(ChartRangeEnum.oneMonth);
    final pastNetWorthChange = pastValueRange.valueChange;

    // Map the 10 most recent transactions into a widget-friendly format
    final recent = transactions
        .take(10)
        .map(
          (t) => {
            "merchant": t.description,
            "category": t.category?.name ?? "Unknown",
            "amount": t.amount.toCurrency(isPrivate),
            "amountNumeric": t.amount,
            "date": t.timeText,
            "pending": t.pending,
          },
        )
        .toList();

    return {
      "updateTime": DateTime.now().toShortMonthWithTime,
      "netWorth": netWorth.value.toCurrency(isPrivate),
      "changeAmount": monthFrame.valueChange.toCurrency(isPrivate),
      "changePercent": "${(monthFrame.percentChange ?? 0).toStringAsFixed(2)}%",
      "numericChange": pastNetWorthChange,
      "dayRange": ChartRangeUtility.asPretty(dayRange, useExtendedPeriodString: true),
      "recentTransactions": recent,
      "theme": theme.value,
    };
  }

  /// Serializes the data and sends it to the native platform via [HomeWidget].
  Future<void> _saveToNative(Map<String, dynamic>? data) async {
    final String jsonString = jsonEncode(data ?? {});
    await HomeWidget.saveWidgetData('widget_data', jsonString);
    await HomeWidget.updateWidget(androidName: 'widget.Overview');
    await HomeWidget.updateWidget(androidName: 'widget.Transactions');
  }
}

/// The top-level function called by the OS when a background task is triggered.
///
/// Because this runs in a separate Isolate, we must create a [ProviderContainer]
/// to access Sprout's data providers.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Manually manage a ProviderContainer for the background isolate
    final container = ProviderContainer();

    try {
      // Apply default auth to grab data in the background of this isolate
      await container.read(authProvider.notifier).applyDefaultAuth();
      // Force-refresh the futures to ensure the widget doesn't show stale data
      await Future.wait([
        container.refresh(userConfigProvider.future),
        container.refresh(totalNetWorthProvider.future),
        container.refresh(transactionsProvider.future),
      ]);

      // Perform the native widget update
      await container.read(widgetSyncProvider.notifier).update();

      return true; // Task succeeded
    } catch (e) {
      return false;
    } finally {
      container.dispose();
    }
  });
}
