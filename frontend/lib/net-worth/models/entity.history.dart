import 'package:flutter/material.dart';
import 'package:sprout/charts/models/chart_range.dart';

/// This class represents a time frame of net worth change.
class EntityHistoryDataPoint {
  final double? percentChange;
  final double valueChange;

  const EntityHistoryDataPoint({required this.valueChange, this.percentChange});

  factory EntityHistoryDataPoint.fromJson(Map<String, dynamic> json) {
    return EntityHistoryDataPoint(
      valueChange: json['valueChange']?.toDouble(),
      percentChange: json['percentChange']?.toDouble(),
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
          parsedHistoricalData[DateTime.parse(key)] = value.toDouble();
        } catch (e) {
          debugPrint('Error parsing historical date $key: $e');
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
