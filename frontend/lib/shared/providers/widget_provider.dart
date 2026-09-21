import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_icon.dart';
import 'package:sprout/net-worth/models/extensions/entity_history_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/shared/models/extensions/color_extensions.dart';
import 'package:sprout/shared/models/extensions/date_extensions.dart';
import 'package:sprout/shared/providers/bg_job_provider.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';
import 'package:sprout/shared/providers/logo_provider.dart';
import 'package:sprout/shared/providers/sse_provider.dart';
import 'package:sprout/shared/widgets/charts/models/chart_range.dart';
import 'package:sprout/transaction/models/extensions/transaction_extensions.dart';
import 'package:sprout/transaction/models/transaction_state.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/user/user_config_provider.dart';
import 'package:workmanager/workmanager.dart';

part 'widget_provider.g.dart';

@Riverpod(keepAlive: true)
class WidgetSync extends _$WidgetSync {
  @override
  Future<void> build() async {
    if (kIsWeb) return;

    // Listen for changes to the auth state
    ref.listen(authProvider, (previous, next) async {
      final authData = next.value;
      if (authData == null) {
        // User logged out or auth is null -> Clear native data
        await _saveToNative(null);
      } else {
        // User logged in -> fetch
        await updateData();
      }
    });

    ref.listen(transactionsProvider(TransactionFilter.defaultFilter), (_, __) => updateData());
    ref.listen(totalNetWorthProvider, (_, __) => updateData());
    ref.listen(userConfigProvider, (_, __) => updateData());
    ref.listen(accountsProvider, (_, __) => updateData());

    ref.listen(sseProvider, (prev, next) {
      if (next.latestData?.event == SSEDataEventEnum.forceUpdate) {
        updateData();
      }
    });

    // Determine initial state on startup
    final initialAuth = ref.read(authProvider).value;
    if (initialAuth != null) {
      await updateData();
    } else {
      await _saveToNative(null);
    }
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
  Future<void> updateData() async {
    final data = await _prepareData();
    await _saveToNative(data);
  }

  /// Downloads the remote image and converts it into a Base64 string for Android RemoteViews.
  /// Inspects raw magic bytes to guarantee valid PNG payloads.
  Future<String?> _getBase64Icon(String? iconUrl) async {
    if (iconUrl == null || iconUrl.isEmpty) return null;
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(iconUrl));
      request.followRedirects = true;
      request.maxRedirects = 5;
      final response = await request.close();
      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        final isPngBitmap =
            bytes.length >= 4 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47;
        if (isPngBitmap) {
          return base64Encode(bytes).replaceAll('\n', '').replaceAll('\r', '').trim();
        } else {
          LoggerProvider.warning("Icon payload is not a PNG (Magic bytes mismatch) from $iconUrl");
        }
      } else {
        LoggerProvider.warning("Failed to fetch icon. Status code: ${response.statusCode} for $iconUrl");
      }
    } catch (e) {
      LoggerProvider.error("Failed to fetch widget PNG icon base64: $e");
    }
    return null;
  }

  /// Directly paints the CategoryIcon look onto a canvas without relying on an element tree layout.
  Future<String> _generateCategoryFallbackBase64(Category? category) async {
    const double canvasSize = 48.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, canvasSize, canvasSize));
    final bgPaint = Paint()..color = const Color(0xFF2C353D);
    canvas.drawCircle(const Offset(canvasSize / 2, canvasSize / 2), canvasSize / 2, bgPaint);
    final iconData = CategoryIcon.iconLibrary[category?.icon] ?? Icons.question_mark_rounded;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 24,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((canvasSize - textPainter.width) / 2, (canvasSize - textPainter.height) / 2),
    );
    final picture = recorder.endRecording();
    final img = await picture.toImage(canvasSize.toInt(), canvasSize.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return base64Encode(pngBytes!.buffer.asUint8List());
  }

  /// Aggregates data from [NetWorth] and [Transactions] providers.
  Future<Map<String, dynamic>> _prepareData() async {
    final userConfig = ref.read(userConfigProvider).value;
    final userConfigAsync = ref.read(userConfigProvider.notifier);
    final theme = userConfigAsync.activeTheme(userConfig);
    final formatter = ref.watch(currencyFormatterProvider);
    final categories = ref.read(categoriesProvider).value ?? [];
    final accounts = ref.read(accountsProvider).value?.accounts ?? [];
    Map<String, Object>? data;
    String failureMessage = "No data available. Check settings.";
    num? pastNetWorthChange;

    // Safety check: If widgets aren't allowed, clear existing data
    if (userConfig != null && userConfig.allowWidgets) {
      try {
        final netWorth = ref.read(totalNetWorthProvider).value;
        final transactions = ref.read(transactionsProvider(TransactionFilter.defaultFilter)).value?.transactions ?? [];
        if (netWorth == null) {
          data = null;
        } else {
          final monthFrame = netWorth.history.getValueByFrame(ChartRangeEnum.oneMonth);
          final dayRange = ChartRangeEnum.oneMonth;
          final pastValueRange = netWorth.history.getValueByFrame(ChartRangeEnum.oneMonth);
          pastNetWorthChange = pastValueRange.valueChange;

          // Map the 10 most recent transactions into a widget-friendly format asynchronously
          final recentFutures = transactions.take(10).map((t) async {
            final category = categories.firstWhereOrNull((c) => c.id == t.categoryId);
            final categoryName = category?.name ?? "Unknown";
            final account = accounts.firstWhereOrNull((a) => a.id == t.accountId);
            final accountName = account?.name ?? "Unknown";
            final websiteUrl = t.extra?.website;
            // Determine the icon to display
            String? iconBase64;
            if (websiteUrl != null && websiteUrl.isNotEmpty) {
              final icon = (await ref.watch(websiteIconProvider(websiteUrl, 24, type: "png").future));
              if (icon.isNotEmpty) iconBase64 = await _getBase64Icon(icon.first);
            }
            iconBase64 ??= await _generateCategoryFallbackBase64(category);

            return {
              "id": t.id,
              "merchant": t.description,
              "category": categoryName,
              "account": accountName,
              "amount": formatter.format(t.amount, handlePrivateMode: false),
              "amountNumeric": t.amount,
              "date": t.timeText,
              "pending": t.pending,
              "iconBase64": iconBase64
            };
          }).toList();

          final recent = await Future.wait(recentFutures);

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
    if (kIsWeb) return; // Widgets are not available on web
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
      await container.read(widgetSyncProvider.notifier).updateData();
      return false;
    }
    try {
      // Force-refresh the futures to ensure the widget doesn't show stale data
      await container.read(userConfigProvider.future);
      await container.read(totalNetWorthProvider.future);
      await container.read(transactionsProvider(TransactionFilter.defaultFilter).future);
      await container.read(categoriesProvider.future);
      await container.read(accountsProvider.future);
      // Perform the native widget update
      await container.read(widgetSyncProvider.notifier).updateData();
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
