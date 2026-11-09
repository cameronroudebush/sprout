import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/net-worth/models/extensions/entity_history_extensions.dart';
import 'package:sprout/net-worth/net_worth_provider.dart';
import 'package:sprout/shared/models/extensions/color_extensions.dart';
import 'package:sprout/shared/models/extensions/date_extensions.dart';
import 'package:sprout/shared/models/widget_image_utility.dart';
import 'package:sprout/shared/providers/bg_job_provider.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/providers/logger_provider.dart';
import 'package:sprout/shared/providers/logo_provider.dart';
import 'package:sprout/shared/providers/sse_provider.dart';
import 'package:sprout/shared/widgets/charts/models/chart_range.dart';
import 'package:sprout/transaction/models/extensions/transaction_extensions.dart';
import 'package:sprout/transaction/models/transaction_state.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/effective_transaction_icon.dart';
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

    ref.listen(
      transactionsProvider(TransactionFilter.defaultFilter),
      (_, __) => updateData(),
    );
    ref.listen(totalNetWorthProvider, (_, __) => updateData());
    ref.listen(portfolioSummaryProvider, (_, __) => updateData());
    ref.listen(majorIndicesProvider, (_, __) => updateData());
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
  /// This task runs every 30 minutes to keep the Home Screen widget up to date
  /// even when the app is not in the foreground.
  Future<void> initializeBackground() async {
    if (!kIsWeb) {
      Workmanager().initialize(callbackDispatcher);
      Workmanager().registerPeriodicTask(
        "widget-update-background",
        "widget-update-task",
        frequency: const Duration(minutes: 30),
        constraints: Constraints(networkType: NetworkType.connected),
      );
    }
  }

  /// The primary entry point for updating native widget data.
  Future<void> updateData() async {
    final data = await _prepareData();
    await _saveToNative(data);
  }

  /// Aggregates data from [NetWorth] and [Transactions] providers.
  Future<Map<String, dynamic>> _prepareData() async {
    final userConfig = ref.read(userConfigProvider).value;
    final userConfigAsync = ref.read(userConfigProvider.notifier);
    final theme = userConfigAsync.activeTheme(userConfig);
    final formatter = ref.read(currencyFormatterProvider);
    final categories = ref.read(categoriesProvider).value ?? [];
    final accounts = ref.read(accountsProvider).value?.accounts ?? [];
    Map<String, Object>? data;
    String failureMessage = "No data available";
    num? pastNetWorthChange;
    num? portfolioDayChange;

    // Safety check: If widgets aren't allowed, clear existing data
    if (userConfig != null && userConfig.allowWidgets) {
      try {
        final netWorth = ref.read(totalNetWorthProvider).value;
        final portfolio = ref.read(portfolioSummaryProvider).value;
        portfolioDayChange = portfolio?.dayChange ?? 0;
        final transactions = ref
                .read(transactionsProvider(TransactionFilter.defaultFilter))
                .value
                ?.transactions ??
            [];
        if (netWorth == null) {
          data = null;
        } else {
          final monthFrame = netWorth.history.getValueByFrame(
            ChartRangeEnum.oneMonth,
          );
          final dayRange = ChartRangeEnum.oneMonth;
          final pastValueRange = netWorth.history.getValueByFrame(
            ChartRangeEnum.oneMonth,
          );
          pastNetWorthChange = pastValueRange.valueChange;

          // Map the 10 most recent transactions into a widget-friendly format asynchronously
          final recentFutures = transactions.take(10).map((t) async {
            final category = categories.firstWhereOrNull(
              (c) => c.id == t.categoryId,
            );
            final categoryName = category?.name ?? "Unknown";
            final account = accounts.firstWhereOrNull(
              (a) => a.id == t.accountId,
            );
            final accountName = account?.name ?? "Unknown";
            final effectiveIcon = getTransactionIconSource(
              t,
              account: account,
              category: category,
            );
            String? resolvedIconUrl;
            if (effectiveIcon.account != null) {
              try {
                final icon = await ref.read(
                  institutionIconProvider(
                    effectiveIcon.account!.institution,
                    48,
                  ).future,
                );
                if (icon.isNotEmpty) resolvedIconUrl = icon.first;
              } catch (e) {
                LoggerProvider.warning(
                  "Failed to fetch institution icon for ${effectiveIcon.account!.institution.name}: $e",
                );
              }
            } else if (effectiveIcon.websiteUrl != null) {
              try {
                final icon = await ref.read(
                  websiteIconProvider(
                    effectiveIcon.websiteUrl!,
                    48,
                    type: "png",
                  ).future,
                );
                if (icon.isNotEmpty) resolvedIconUrl = icon.first;
              } catch (e) {
                LoggerProvider.warning(
                  "Failed to fetch website icon for ${effectiveIcon.websiteUrl}: $e",
                );
              }
            }
            final iconBase64 = await WidgetImageUtility.getSquircleBase64(
              imageUrl: resolvedIconUrl,
              fallbackIcon: effectiveIcon.fallbackIcon,
              fallbackBgColor: theme.colorScheme.primaryContainer,
              iconColor: theme.colorScheme.onPrimaryContainer,
            );
            return {
              "id": t.id,
              "merchant": t.description,
              "category": categoryName,
              "account": accountName,
              "amount": formatter.format(t.amount, handlePrivateMode: false),
              "amountNumeric": t.amount,
              "date": t.timeText,
              "pending": t.pending,
              "iconBase64": iconBase64,
            };
          }).toList();

          final recent = await Future.wait(recentFutures);
          final portfolioChangeAmount = portfolioDayChange;
          List<MarketIndexDto> majorIndices = [];
          try {
            majorIndices =
                (await ref.read(majorIndicesProvider.future)).toList();
          } catch (e) {
            LoggerProvider.warning(
                "Failed to fetch major indices for widget: $e");
          }
          const indexOrder = {"^GSPC": 0, "^DJI": 1, "^IXIC": 2};
          majorIndices.sort(
            (a, b) => (indexOrder[a.symbol] ?? 3).compareTo(
              indexOrder[b.symbol] ?? 3,
            ),
          );

          data = {
            "updateTime": DateTime.now().toShortMonthWithTime,
            "netWorth": formatter.format(
              netWorth.value,
              handlePrivateMode: false,
            ),
            "changeAmount": formatter.format(
              monthFrame.valueChange,
              handlePrivateMode: false,
            ),
            "changePercent":
                "${(monthFrame.percentChange ?? 0).toStringAsFixed(2)}%",
            "numericChange": pastNetWorthChange,
            "dayRange": ChartRangeUtility.asPretty(
              dayRange,
              useExtendedPeriodString: true,
            ),
            "recentTransactions": recent,
            "portfolioChange":
                "${portfolioChangeAmount >= 0 ? "+" : "-"}${formatter.format(portfolioChangeAmount.abs(), handlePrivateMode: false)}",
            "portfolioChangePercent":
                "${(portfolio?.dayChangePercent ?? 0) >= 0 ? "+" : ""}${(portfolio?.dayChangePercent ?? 0).toStringAsFixed(2)}%",
            "hasPendingNavs": portfolio?.hasPendingNavs ?? false,
            "majorIndices": majorIndices.take(3).map((index) {
              final isValid = index.type != MarketIndexDtoTypeEnum.INVALID;
              final isPositive = index.change >= 0;
              return {
                "name": index.name,
                "change": isValid
                    ? "${isPositive ? "+" : "-"}${NumberFormat("#,##0.0").format(index.change.abs())} pts"
                    : "—",
                "changePercent": isValid
                    ? "${index.changePercent >= 0 ? "+" : ""}${(index.changePercent * 100).toStringAsFixed(2)}%"
                    : "—",
                "statusColor": (isValid
                        ? (isPositive
                            ? Colors.greenAccent
                            : theme.colorScheme.error)
                        : (theme.textTheme.bodySmall?.color ?? Colors.grey))
                    .toHex(),
              };
            }).toList(),
          };
        }
      } catch (e) {
        // If there is an error, just log it and set a failure message
        LoggerProvider.error("Failed to update widgets: $e");
      }
    } else if (userConfig == null) {
      // User must be logged in
      failureMessage = "Session Expired";
    } else {
      failureMessage = "Widget Setting Disabled";
    }

    return {
      "data": data,
      "failureMessage": failureMessage,
      "theme": {
        "bgColor": theme.appBarTheme.backgroundColor!.toHex(),
        "cardColor": theme.cardColor.toHex(),
        "txtColor": (theme.textTheme.bodyLarge?.color ?? Colors.white).toHex(),
        "txtColorMuted":
            (theme.textTheme.bodySmall?.color ?? Colors.grey).toHex(),
        "primaryColor": theme.primaryColor.toHex(),
        "accentColor": theme.colorScheme.secondary.toHex(),
        "statusColor": (pastNetWorthChange != null && pastNetWorthChange >= 0
                ? Colors.greenAccent
                : theme.colorScheme.error)
            .toHex(),
        "portfolioStatusColor":
            (portfolioDayChange == null || portfolioDayChange >= 0
                    ? Colors.greenAccent
                    : theme.colorScheme.error)
                .toHex(),
        "dividerColor": theme.dividerColor.toHex(),
      },
    };
  }

  /// Serializes the data and sends it to the native platform via [HomeWidget].
  Future<void> _saveToNative(Map<String, dynamic>? data) async {
    if (kIsWeb) return; // Widgets are not available on web
    final String jsonString = jsonEncode(data ?? {});
    await HomeWidget.saveWidgetData('widget_data', jsonString);
    await HomeWidget.updateWidget(androidName: 'widget.Overview');
    await HomeWidget.updateWidget(androidName: 'widget.Transactions');
    await HomeWidget.updateWidget(androidName: 'widget.Portfolio');
  }
}

/// The top-level function called by the OS when a background task is triggered.
///
/// Because this runs in a separate Isolate, we must create a [ProviderContainer]
/// to access Sprout's data providers.
@pragma('vm:entry-point')
void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().executeTask((task, inputData) async {
    final (container, user) = await BackgroundJobProvider.entry(
      "Widget-Provider",
    );
    if (user == null) {
      // No user? Update anyways. Since auth will be null, we'll just write session expired.
      await container.read(widgetSyncProvider.notifier).updateData();
      return false;
    }
    try {
      // Force-refresh the futures to ensure the widget doesn't show stale data
      await container.read(userConfigProvider.future);
      await container.read(totalNetWorthProvider.future);
      await container.read(portfolioSummaryProvider.future);
      await container.read(
        transactionsProvider(TransactionFilter.defaultFilter).future,
      );
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
