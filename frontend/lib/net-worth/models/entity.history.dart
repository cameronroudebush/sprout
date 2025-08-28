import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/core/logger.dart';

/// This class represents a time frame of net worth change.
class EntityHistoryDataPoint {
  final double? percentChange;
  final double valueChange;
  Map<DateTime, double> history;

  EntityHistoryDataPoint({required this.valueChange, required this.history, this.percentChange});

  factory EntityHistoryDataPoint.fromJson(Map<String, dynamic> json) {
    Map<DateTime, double> parsedHistoricalData = {};
    (json['history'] as Map).forEach((key, value) {
      try {
        final ms = int.parse(key.toString());
        final date = DateTime.fromMillisecondsSinceEpoch(ms);
        parsedHistoricalData[date] = double.parse(value.toString());
      } catch (e) {
        LoggerService.error('Error parsing historical date $key on point: $e');
      }
    });

    return EntityHistoryDataPoint(
      valueChange: json['valueChange']?.toDouble(),
      percentChange: json['percentChange']?.toDouble(),
      history: parsedHistoricalData,
    );
  }
}

/// Provides information for how net worth has progressed over time
class EntityHistory {
  EntityHistoryDataPoint last1Day;
  EntityHistoryDataPoint last7Days;
  EntityHistoryDataPoint lastMonth;
  EntityHistoryDataPoint lastThreeMonths;
  EntityHistoryDataPoint lastSixMonths;
  EntityHistoryDataPoint lastYear;
  EntityHistoryDataPoint allTime;

  Map<DateTime, double> historicalData;
  String? connectedId;

  EntityHistory({
    required this.last1Day,
    required this.last7Days,
    required this.lastMonth,
    required this.lastThreeMonths,
    required this.lastSixMonths,
    required this.lastYear,
    required this.allTime,
    required this.historicalData,
    this.connectedId,
  });

  factory EntityHistory.fromJson(Map<String, dynamic> json) {
    Map<DateTime, double> parsedHistoricalData = {};
    if (json.containsKey('historicalData') && json['historicalData'] is Map) {
      (json['historicalData'] as Map).forEach((key, value) {
        try {
          final ms = int.parse(key.toString());
          final date = DateTime.fromMillisecondsSinceEpoch(ms);
          parsedHistoricalData[date] = double.parse(value.toString());
        } catch (e) {
          LoggerService.error('Error parsing historical date $key: $e');
        }
      });
    }

    return EntityHistory(
      last1Day: EntityHistoryDataPoint.fromJson(json['last1Day']),
      last7Days: EntityHistoryDataPoint.fromJson(json['last7Days']),
      lastMonth: EntityHistoryDataPoint.fromJson(json['lastMonth']),
      lastThreeMonths: EntityHistoryDataPoint.fromJson(json['lastThreeMonths']),
      lastSixMonths: EntityHistoryDataPoint.fromJson(json['lastSixMonths']),
      lastYear: EntityHistoryDataPoint.fromJson(json['lastYear']),
      allTime: EntityHistoryDataPoint.fromJson(json['allTime']),
      historicalData: parsedHistoricalData,
      connectedId: json['connectedId'],
    );
  }

  /// Returns the value by the given time frame as supported in the above properties
  EntityHistoryDataPoint getValueByFrame(ChartRange frame) {
    switch (frame) {
      case ChartRange.oneDay:
        return last1Day;
      case ChartRange.sevenDays:
        return last7Days;
      case ChartRange.oneMonth:
        return lastMonth;
      case ChartRange.threeMonths:
        return lastThreeMonths;
      case ChartRange.sixMonths:
        return lastSixMonths;
      case ChartRange.oneYear:
        return lastYear;
      case ChartRange.allTime:
        return allTime;
    }
  }
}
