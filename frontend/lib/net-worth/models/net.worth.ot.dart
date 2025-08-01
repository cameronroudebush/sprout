import 'package:flutter/material.dart';
import 'package:sprout/charts/models/chart_range.dart';

/// This class represents a time frame of net worth change.
class NetWorthFrameData {
  final double? percentChange;
  final double valueChange;

  const NetWorthFrameData({required this.valueChange, this.percentChange});

  factory NetWorthFrameData.fromJson(Map<String, dynamic> json) {
    return NetWorthFrameData(
      valueChange: json['valueChange']?.toDouble(),
      percentChange: json['percentChange']?.toDouble(),
    );
  }
}

/// Provides information for how net worth has progressed over time
class HistoricalNetWorth {
  NetWorthFrameData last1Day;
  NetWorthFrameData last7Days;
  NetWorthFrameData lastMonth;
  NetWorthFrameData lastThreeMonths;
  NetWorthFrameData lastSixMonths;
  NetWorthFrameData lastYear;
  NetWorthFrameData allTime;

  Map<DateTime, double> historicalData;
  String? accountId;

  HistoricalNetWorth({
    required this.last1Day,
    required this.last7Days,
    required this.lastMonth,
    required this.lastThreeMonths,
    required this.lastSixMonths,
    required this.lastYear,
    required this.allTime,
    required this.historicalData,
    this.accountId,
  });

  factory HistoricalNetWorth.fromJson(Map<String, dynamic> json) {
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

    return HistoricalNetWorth(
      last1Day: NetWorthFrameData.fromJson(json['last1Day']),
      last7Days: NetWorthFrameData.fromJson(json['last7Days']),
      lastMonth: NetWorthFrameData.fromJson(json['lastMonth']),
      lastThreeMonths: NetWorthFrameData.fromJson(json['lastThreeMonths']),
      lastSixMonths: NetWorthFrameData.fromJson(json['lastSixMonths']),
      lastYear: NetWorthFrameData.fromJson(json['lastYear']),
      allTime: NetWorthFrameData.fromJson(json['allTime']),
      historicalData: parsedHistoricalData,
      accountId: json['accountId'],
    );
  }

  /// Returns the value by the given time frame as supported in the above properties
  NetWorthFrameData getValueByFrame(ChartRange frame) {
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
