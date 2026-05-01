import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/net-worth/models/extensions/entity_history_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/shared/models/extensions/color_extensions.dart';
import 'package:sprout/shared/models/extensions/date_extensions.dart';
import 'package:sprout/shared/providers/bg_job_provider.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';
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
    if (kIsWeb) return;

    // Listen for when user is authenticated
    ref.listen(authProvider, (prev, next) {
      if (next.value == null && prev?.value != null) {
        _saveToNative(null); // On logout, wipe data
      } else if (next.value != null) {
        update();
      }
    });

    ref.listen(transactionsProvider, (_, __) => update());
    ref.listen(totalNetWorthProvider, (_, __) => update());
    ref.listen(userConfigProvider, (_, __) => update());

    /// Listen for SSE events to trigger immediate widget updates.
    ref.listen(sseProvider, (prev, next) async {
      final data = next.latestData;
      if (data?.event == SSEDataEventEnum.forceUpdate) {
        await update();
      }
    });
  }

  /// Initializes the [Workmanager] and registers a periodic background task.
  ///
  /// This task runs hourly to ensure the Home Screen widget stays up to date
  /// even when the app is not in the foreground.
  Future<void> initializeBackground() async {
    if (!kIsWeb) {
      Workmanager().initialize(callbackDispatcher);
      Workmanager().registerPeriodicTask(
        "widget-update-background",
        "widget-update-task",
        frequency: const Duration(hours: 1),
        constraints: Constraints(networkType: NetworkType.connected),
      );
    }
  }

  /// The primary entry point for updating native widget data.
  Future<void> update() async {
    final data = await _prepareData();
    await _saveToNative(data);
  }

  /// Aggregates data from [NetWorth] and [Transactions] providers.
  Future<Map<String, dynamic>> _prepareData() async {
    final userConfig = ref.read(userConfigProvider).value;
    final userConfigAsync = ref.read(userConfigProvider.notifier);
    final theme = userConfigAsync.activeTheme(userConfig);
    final formatter = ref.watch(currencyFormatterProvider);
    Map<String, Object>? data;
    String failureMessage = "No data available. Check settings.";
    num? pastNetWorthChange;

    // Safety check: If widgets aren't allowed, clear existing data
    if (userConfig != null && userConfig.allowWidgets) {
      try {
        final netWorth = ref.read(totalNetWorthProvider).value;
        final transactions = ref.read(transactionsProvider).value?.transactions ?? [];
        if (netWorth == null) {
          data = null;
        } else {
          final monthFrame = netWorth.history.getValueByFrame(ChartRangeEnum.oneMonth);
          final dayRange = ChartRangeEnum.oneMonth;
          final pastValueRange = netWorth.history.getValueByFrame(ChartRangeEnum.oneMonth);
          pastNetWorthChange = pastValueRange.valueChange;

          // Map the 10 most recent transactions into a widget-friendly format
          final recent = transactions
              .take(10)
              .map(
                (t) => {
                  "merchant": t.description,
                  "category": t.category?.name ?? "Unknown",
                  "amount": formatter.format(t.amount, handlePrivateMode: false),
                  "amountNumeric": t.amount,
                  "date": t.timeText,
                  "pending": t.pending,
                },
              )
              .toList();

          data = {
            "updateTime": DateTime.now().toShortMonthWithTime,
            "netWorth": formatter.format(netWorth.value, handlePrivateMode: false),
            "changeAmount": formatter.format(monthFrame.valueChange, handlePrivateMode: false),
            "changePercent": "${(monthFrame.percentChange ?? 0).toStringAsFixed(2)}%",
            "numericChange": pastNetWorthChange,
            "dayRange": ChartRangeUtility.asPretty(dayRange, useExtendedPeriodString: true),
            "recentTransactions": recent,
          };
        }
      } catch (e) {
        // If there is an error, just log it and set a failure message
        LoggerProvider.error("Failed to update widgets: $e");
        failureMessage = "Failed to update widgets, check logs";
      }
    } else if (userConfig == null) {
      // User must be logged in
      failureMessage = "Session expired";
    }

    return {
      "data": data,
      "failureMessage": failureMessage,
      "theme": {
        "bgColor": theme.appBarTheme.backgroundColor!.toHex(),
        "cardColor": theme.cardColor.toHex(),
        "txtColor": (theme.textTheme.bodyLarge?.color ?? Colors.white).toHex(),
        "txtColorMuted": (theme.textTheme.bodySmall?.color ?? Colors.grey).toHex(),
        "primaryColor": theme.primaryColor.toHex(),
        "accentColor": theme.colorScheme.secondary.toHex(),
        "statusColor":
            (pastNetWorthChange != null && pastNetWorthChange >= 0 ? Colors.greenAccent : theme.colorScheme.error)
                .toHex(),
        "dividerColor": theme.dividerColor.toHex(),
      }
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
    final (container, user) = await BackgroundJobProvider.entry("Widget-Provider");
    if (user == null) {
      // No user? Update anyways. Since auth will be null, we'll just write session expired.
      await container.read(widgetSyncProvider.notifier).update();
      return false;
    }
    try {
      // Force-refresh the futures to ensure the widget doesn't show stale data
      await container.read(userConfigProvider.future);
      await container.read(totalNetWorthProvider.future);
      await container.read(transactionsProvider.future);
      // Perform the native widget update
      await container.read(widgetSyncProvider.notifier).update();
      LoggerProvider.debug("Background widget update successful");
      return true;
    } catch (e) {
      LoggerProvider.error(e);
      return false;
    } finally {
      container.dispose();
    }
  });
}
