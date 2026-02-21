import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/logger.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/provider_services.dart';
import 'package:sprout/core/utils/formatters.dart';

/// A provider that allows us to send data off to the widgets as needed
class WidgetProvider extends BaseProvider<CoreApi> with SproutProviders {
  static const platform = MethodChannel('net.croudebush.sprout/widget');

  WidgetProvider(super.api);

  /// Given a map of data, inserts it into the main activity data store
  Future<void> updateWidgetData(Map<String, dynamic> data) async {
    try {
      final String jsonString = jsonEncode(data);
      await platform.invokeMethod('updateData', {"json": jsonString});
    } on PlatformException catch (e) {
      LoggerService.error("Failed to sync widget: ${e.message}");
    }
  }

  /// Returns the data we wish to populate to the widget based on our provider data
  Future<Map<String, dynamic>> getData() async {
    // TODO: Improve to use real data
    // Fake data generation
    final double netWorth = 91765.54;
    final double changeAmount = 2370.29;
    final double fakeChangePercent = 2.65;
    final String dayRange = "1 month";

    // Recent Transactions Mock Data
    final List<Map<String, dynamic>> recentTransactions = [
      {"merchant": "Starbucks", "category": "Dining", "amount": "-\$5.42", "amountNumeric": -5.42, "date": "Today"},
      {
        "merchant": "Apple.com/Bill",
        "category": "Services",
        "amount": "-\$14.99",
        "amountNumeric": -14.99,
        "date": "Yesterday",
      },
      {
        "merchant": "Employer Deposit",
        "category": "Income",
        "amount": "+\$2,400.00",
        "amountNumeric": 2400.00,
        "date": "Feb 20",
      },
      {
        "merchant": "Whole Foods",
        "category": "Groceries",
        "amount": "-\$84.20",
        "amountNumeric": -84.20,
        "date": "Feb 19",
      },
    ];

    return {
      "netWorth": getFormattedCurrency(netWorth),
      "changeAmount": getFormattedCurrency(changeAmount),
      "changePercent": "${fakeChangePercent.toStringAsFixed(2)}%",
      "numericChange": changeAmount,
      "dayRange": dayRange,
      "recentTransactions": recentTransactions,
    };
  }

  @override
  postLogin() async {
    await updateWidgetData(await getData());
  }
}
