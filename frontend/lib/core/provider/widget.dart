import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/core/logger.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/provider_services.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/net-worth/model/entity_history_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/transaction/model/transaction_extensions.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:workmanager/workmanager.dart';

/// Top level dispatcher that uses worker manager to populate background tasks to run.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      LoggerService.info("Executing background widget update");
      WidgetsFlutterBinding.ensureInitialized();
      await ServiceLocator.setupBackgroundIsolate();

      // Fetch fresh data from the backend
      await ServiceLocator.get<NetWorthProvider>().populateTotal();
      await ServiceLocator.get<TransactionProvider>().populateInitial();

      // Fire the widget update
      final widgetProvider = ServiceLocator.get<WidgetProvider>();
      await widgetProvider.update();

      return Future.value(true);
    } catch (e) {
      LoggerService.error("Failed background widget sync: $e");
      return Future.value(false);
    }
  });
}

/// A provider that allows us to send data off to the widgets as needed
class WidgetProvider extends BaseProvider<CoreApi> with SproutProviders {
  static const platform = MethodChannel('net.croudebush.sprout/widget');

  WidgetProvider(super.api);

  /// Given a map of data, inserts it into the main activity data store
  Future<void> _updateWidgetData(Map<String, dynamic>? data) async {
    try {
      final String jsonString = jsonEncode(data ?? {});
      await platform.invokeMethod('updateData', {"json": jsonString});
    } on PlatformException catch (e) {
      LoggerService.error("Failed to sync widget: ${e.message}");
    }
  }

  /// Returns the data we wish to populate to the widget based on our provider data
  Future<Map<String, dynamic>?> _getData() async {
    if (netWorthProvider.total != null && transactionProvider.transactions.isNotEmpty) {
      final total = netWorthProvider.total!;
      final currentNetWorth = total.value;
      final dayRange = ChartRangeEnum.oneMonth;
      final pastValueRange = total.history.getValueByFrame(ChartRangeEnum.oneMonth);
      final pastNetWorthChange = pastValueRange.valueChange;
      final percentageChange = pastValueRange.percentChange ?? 0;

      final recentTransactions = transactionProvider.transactions
          .sublist(0, 10)
          .map(
            (e) => {
              "merchant": e.description,
              "category": e.category?.name ?? "Unknown",
              "amount": getFormattedCurrency(e.amount),
              "amountNumeric": e.amount,
              "date": e.timeText,
              "pending": e.pending,
            },
          )
          .toList();

      return {
        "updateTime": DateTime.now().toShortMonthWithTime,
        "netWorth": getFormattedCurrency(currentNetWorth),
        "changeAmount": getFormattedCurrency(pastNetWorthChange),
        "changePercent": "${percentageChange.toStringAsFixed(2)}%",
        "numericChange": pastNetWorthChange,
        "dayRange": ChartRangeUtility.asPretty(dayRange, useExtendedPeriodString: true),
        "recentTransactions": recentTransactions,
      };
    } else {
      return null;
    }
  }

  /// Updates all our data for what we want to use with the widgets. Considers the
  ///   config value for if we're allowed to set widget data or not.
  Future<void> update() async {
    if (userConfigProvider.currentUserConfig != null) {
      if (userConfigProvider.currentUserConfig!.allowWidgets) {
        await _updateWidgetData(await _getData());
      } else {
        await _updateWidgetData(null);
      }
    }
  }

  @override
  postLogin() async {
    // Update the data immediately after the login so we have the initial data set
    await update();
    // Initialize Workmanager
    Workmanager().initialize(callbackDispatcher);
    // Register the hourly background task for this widget
    Workmanager().registerPeriodicTask(
      "widget-update-background",
      "widget-update-task",
      frequency: const Duration(hours: 1), // Run updates every hour
      constraints: Constraints(
        networkType: NetworkType.connected, // Ensure tasks are only run if we have a connection
      ),
    );
  }
}
